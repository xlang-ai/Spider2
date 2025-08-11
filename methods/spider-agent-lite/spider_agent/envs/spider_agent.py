import logging
import os
import subprocess
import tempfile
import time
from typing import Callable, Any, Optional, Tuple

from typing import List, Dict, Union
from docker.models.containers import Container
from docker.client import DockerClient
from docker.errors import ImageNotFound
import gymnasium as gym
import shutil, pathlib, docker, time, copy
from spider_agent.controllers.python import PythonController
from spider_agent.controllers.setup import SetupController
from spider_agent.envs.utils import *
from spider_agent import configs
from spider_agent.agent.action import Action, Bash, Terminate, CreateFile, EditFile, LOCAL_DB_SQL, BIGQUERY_EXEC_SQL, BQ_GET_TABLES, BQ_GET_TABLE_INFO, BQ_SAMPLE_ROWS, SNOWFLAKE_EXEC_SQL
import signal
import sys

logger = logging.getLogger("spider_agent.env")

Metric = Callable[[Any, Any], float]
Getter = Callable[[gym.Env, Dict[str, Any]], Any]


# constants
START_UP_DELAY = 2 # start up delay for docker container
DEFAULT_TIME_OUT = 200 # default waiting time for each action
MAX_OBS_LENGTH = 40000
EMPTY_DATA_PATH = 'spider_agent/data/empty' # an empty data directory
DEFAULT_IMAGE_DIR = 'spider_agent/images' # default directory to store docker images
DEFAULT_WORK_DIR = '/workspace' # default working directory in the container
DEFAULT_MNT_DIR = 'spider_agent/mnt' # default directory to copy and mount data path, also the output directory
TASK_FINISHED = "task_finished" # infos key
ACTION_EXEC = "action_executed" # infos key


class Spider_Agent_Env(gym.Env):
    """
    DesktopEnv with OpenAI Gym interface.
    Fixme: refactor the logic when implementing the multi-process version
    """
    def __init__(self, env_config, task_config, cache_dir, mnt_dir):
        """
        Args:
            path_to_vm (str): path to .vmx file
            action_space (str): "computer_13" | "pyautogui"

            task_config (Dict[str, Any]): manages task configs integratedly,
              including
              * base snapshot
              * task id (uuid)
              * instruction
              * setup config

            tmp_dir (str): temporary directory to store trajectory stuffs like
              the extracted screenshots
            cache_dir (str): cache directory to cache task-related stuffs like
              reference file for evaluation
        """
        super().__init__()
        self.task_config = task_config
        self.cache_dir_base = cache_dir
        self.container_name = env_config['init_args']['name']
        self.image_name = env_config['image_name']
        self.mnt_dir = mnt_dir
        self.work_dir = DEFAULT_WORK_DIR
        self.kwargs = env_config['init_args']

        self._set_task_info(task_config)
        logger.info("Initializing...")
        self._construct_container()
        
        self.controller = PythonController(container=self.container, work_dir=self.work_dir)
        self.setup_controller = SetupController(container=self.container, cache_dir=self.cache_dir)
        
        logger.info("Setting up environment...")
        
        self.setup_controller.setup(self.config)
        self.init_files_hash = self._get_env_files_hash()
        time.sleep(2)
        logger.info("Environment setup complete.")

        signal.signal(signal.SIGINT, self._cleanup)
        signal.signal(signal.SIGTERM, self._cleanup)
        
        
        
    def _set_task_info(self, task_config: Dict[str, Any]):
        self.task_id: str = task_config['instance_id']
        self.cache_dir: str = os.path.join(self.cache_dir_base, self.task_id)
        # os.makedirs(self.cache_dir, exist_ok=True)
        self.instruction = task_config["question"]

        self.config = task_config["config"] if "config" in task_config else []
        self.post_process_func = task_config["post_process"] if "post_process" in task_config else []
        
    def close(self):
        self.container.stop()
        self.container.remove()
        logger.info(f"Container {self.container_name} stopped and removed.")

    def _cleanup(self, signum, frame):
        if self.container:
            self.container.remove(force=True)
            print("remove container")
        sys.exit(0)
        
    def _construct_container(self):
        
        client = docker.from_env()
        container_name = self.container_name
        #### delete existing container
        try:
            container = client.containers.get(container_name)
            container.stop()
            container.remove()
            print(f"Container {container_name} stopped and removed.")
        except docker.errors.NotFound:
            pass
        except docker.errors.APIError as e:
            pass
        
        create_folder_if_not_exists(self.mnt_dir)
        src_dir = pathlib.Path(self.mnt_dir).absolute().__str__()
        delete_files_in_folder(self.mnt_dir)
        
        volumes = {src_dir: {'bind': self.work_dir, 'mode': 'rw'}}
        allowed_params = ['command', 'ports', 'restart_policy', 'entrypoint', 'hostname', 'domainname', 'name', 'user', 'mac_address', 'platform', 'network_mode', 'network_disabled', 'healthcheck', "environment"]
        kwargs = {k: self.kwargs[k] for k in self.kwargs if k in allowed_params}
        extra_params = {'detach': True, 'tty': True, 'stdout': True, 'stderr': True, 'stdin_open': True, **kwargs}

        try:
            client: DockerClient = docker.from_env()
            image = client.images.get(self.image_name)
            self.container: Container = client.containers.run(image=image, volumes=volumes, **extra_params)
        except ImageNotFound as e:
            dockerfile_path = os.path.join(DEFAULT_IMAGE_DIR, self.image_name)
            if os.path.exists(dockerfile_path):
                logger.info(f"Image {self.image_name} not found, try to build from dockerfile {dockerfile_path} ...")
                image = client.images.build(path=dockerfile_path, tag=self.image_name, rm=True)[0]
            else:
                logger.info(f"Image {self.image_name} not found, try to pull from Dockerhub ...")
                image = client.images.pull(self.image_name)[0]
            self.container: Container = client.containers.run(image=image, volumes=volumes, **extra_params)
        except Exception as e:
            logger.info(f"Failed to construct container from image {self.image_name} with error: {e}")
            raise e

        time.sleep(START_UP_DELAY)
        logger.info(f"Connected to container[name={self.container.name}, id={self.container.id}] from image {self.image_name} ...")    
        
        return self.container

    def _get_env_files_hash(self) -> Dict[str, str]:
        """
        Returns:
            Dict[str, str]: a dictionary of the hash of the files in the
              environment
        """
        files_hash = {}
        for root, dirs, files in os.walk(self.mnt_dir):
            for f in files:
                file_path = os.path.join(root, f)
                files_hash[file_path] = calculate_sha256(file_path)
        return files_hash
    

    def post_process(self):
        """
        Evaluate whether the task is successfully completed.
        """
        diff_files = self._find_diff_files_init(self.init_files_hash)

        post_process_files = []
        errors = []
        for post_process_f in self.post_process_func:
            process_function = getattr(configs, post_process_f, None)
            post_files, error = process_function(self.mnt_dir, self.controller)
            post_files = post_files if isinstance(post_files, list) else list(post_files)
            post_process_files.extend(post_files)
            errors.append(error)

        return {**diff_files, "post_process_files": post_process_files, "error": errors}

    def _find_diff_files_init(self, init_file_dict)-> Dict:
        init_file_paths = init_file_dict.keys()
        added_files_list = []
        changed_files_list = []
        for root, dirs, files in os.walk(self.mnt_dir):
            for f in files:
                file_path = os.path.join(root, f)
                if file_path not in init_file_paths:
                    added_files_list.append(file_path)
                else:
                    if init_file_dict[file_path] != calculate_sha256(file_path):
                        changed_files_list.append(file_path)
        return {"added_files": added_files_list, "changed_files": changed_files_list}

    
    def step(self, action: Action):
        try:
            with timeout(DEFAULT_TIME_OUT,"Action execution time exceeded!"):
                done = False
                if isinstance(action, Bash):
                    observation = self.execute_code_action(action)
                elif isinstance(action, BQ_GET_TABLES):
                    observation = self.controller.execute_bq_get_tables(action)
                elif isinstance(action, BQ_GET_TABLE_INFO):
                    observation = self.controller.execute_bq_get_table_info(action)
                elif isinstance(action, BQ_SAMPLE_ROWS):
                    observation = self.controller.execute_bq_sample_rows(action)
                elif isinstance(action, BIGQUERY_EXEC_SQL):
                    observation = self.controller.execute_bq_exec_sql_query(action)
                elif isinstance(action, SNOWFLAKE_EXEC_SQL):
                    observation = self.controller.execute_sf_exec_sql_query(action)
                elif isinstance(action, LOCAL_DB_SQL):
                    observation = self.execute_sql_action(action)
                elif isinstance(action, CreateFile):
                    observation = self.create_file_action(action)
                elif isinstance(action, EditFile):
                    observation = self.edit_file_action(action)
                elif isinstance(action, Terminate):
                    observation = "Terminate"
                    done = True
                else:
                    raise ValueError(f"Unrecognized action type {action.action_type} !")
        except TimeoutError as e:
            observation = str(e)
        
        observation = self._handle_observation(observation)
        # logger.info("Observation: %s", observation)
        return observation, done
    
    def _handle_observation(self, observation):
        max_length = MAX_OBS_LENGTH  
        if len(observation) > max_length:
            truncated_observation = observation[:max_length] + "\n[Observation too long, truncated; Try other commands to get the left part.]"
            return truncated_observation
        return observation


    def execute_code_action(self, action: Bash):
        """ Execute action in bash shell """
        
        obs = self.controller.execute_command(action.code)
        if obs is None or obs == '':
            obs = "Command executed successfully. No output."
        
        return obs

    
    def execute_sql_action(self, action: LOCAL_DB_SQL):
        """ Execute action in sql"""
        obs = self.controller.execute_sql_code(action.file_path, action.code, action.output)
        if obs is None or obs == '':
            obs = f"SQL command executed successfully. No output."
        
        return obs
    
    def create_file_action(self, action: CreateFile):
        obs = self.controller.create_file(action.filepath, action.code)
        if obs is None or obs == '':
            real_file_path = self.controller.get_real_file_path(action.filepath)
            valid, error = is_file_valid(real_file_path)
            if valid:
                obs = f"File {action.filepath} created and written successfully."
            else:
                obs = f"Falied to validate file {action.filepath}, error: {error}"
        return obs
    
    def edit_file_action(self, action: EditFile):
        obs = self.controller.edit_file(action.filepath, action.code)
        if obs is None or obs == '':
            real_file_path = self.controller.get_real_file_path(action.filepath)
            valid, error = is_file_valid(real_file_path)
            if valid:
                obs = f"File {action.filepath} edited successfully."
            else:
                obs = f"Falied to validate file {action.filepath}, error: {error}"
        return obs
    
    
    
    def execute_tmp_action(self, action: Union[BQ_GET_TABLES, BQ_GET_TABLE_INFO, BQ_SAMPLE_ROWS]):
        """ Execute action in sql"""
        obs = self.controller.execute_sql_code(action.file_path, action.code, action.output)
        if obs is None or obs == '':
            obs = f"SQL command executed successfully. No output."
        
        return obs
    