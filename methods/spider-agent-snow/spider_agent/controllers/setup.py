import json
import os


import shutil
import logging
from typing import Any, Union, Optional
from typing import Dict, List
import uuid
import requests
import docker
import shutil
from spider_agent import configs


FILE_PATH = os.path.dirname(os.path.abspath(__file__))
logger = logging.getLogger("spider_agent.setup")


class SetupController:
    def __init__(self, container, cache_dir):
        self.cache_dir = cache_dir
        self.container = container
        self.mnt_dir = [mount['Source'] for mount in container.attrs['Mounts']][0]
        
    def setup(self, config: List[Dict[str, Any]]):
        """
        Args:
            config (List[Dict[str, Any]]): list of dict like {str: Any}. each
              config dict has the structure like
                {
                    "type": str, corresponding to the `_{:}_setup` methods of
                      this class
                    "parameters": dick like {str, Any} providing the keyword
                      parameters
                }
        """  
        for cfg in config:
            config_type: str = cfg["type"]
            parameters: Dict[str, Any] = cfg["parameters"]

            setup_function: str = "_{:}_setup".format(config_type)

            if hasattr(self, setup_function):
                # Assumes all the setup the functions should follow this name
                # protocol
                # assert hasattr(self, setup_function), f'Setup controller cannot find init function {setup_function}'
                getattr(self, setup_function)(**parameters)
                logger.info("SETUP: %s(%s)", setup_function, str(parameters))
            else:
                # customized setup functions
                setup_function: str = "{:}_setup".format(config_type)
                config_function = getattr(configs, setup_function, None)
                assert config_function is not None, f'Setup controller cannot find function {setup_function}'
                config_function(self, **parameters)
                logger.info("SETUP: %s(%s)", setup_function, str(parameters))    
    
    
    def _download_setup(self, files: List[Dict[str, str]]):
        """
        Args:
            files (List[Dict[str, str]]): files to download. lisf of dict like
              {
                "url": str, the url to download
                "path": str, the path on the VM to store the downloaded file
              }
        """
        for f in files:
            url: str = f["url"]
            path: str = f["path"]

            cache_path: str = os.path.join(self.cache_dir, "{:}_{:}".format(
                uuid.uuid5(uuid.NAMESPACE_URL, url),
                os.path.basename(path)))
            if not url or not path:
                raise Exception(f"Setup Download - Invalid URL ({url}) or path ({path}).")

            if not os.path.exists(cache_path):
                max_retries = 3
                downloaded = False
                e = None
                for i in range(max_retries):
                    try:
                        response = requests.get(url, stream=True, timeout=10)
                        response.raise_for_status()

                        with open(cache_path, 'wb') as f:
                            for chunk in response.iter_content(chunk_size=8192):
                                if chunk:
                                    f.write(chunk)
                        logger.info("File downloaded successfully")
                        downloaded = True
                        break

                    except requests.RequestException as e:
                        logger.error(
                            f"Failed to download {url} caused by {e}. Retrying... ({max_retries - i - 1} attempts left)")
                if not downloaded:
                    raise requests.RequestException(f"Failed to download {url}. No retries left. Error: {e}")
            shutil.copy(cache_path, os.path.join(self.mnt_dir, os.path.basename(path)))

        
        
    def _execute_setup(self, command: str):
        """
        Args:
            command (List[str]): the command to execute on the VM
        """
        cmd = ["sh", "-c", command]
        exit_code, output = self.container.exec_run(cmd)
        return output.decode("utf-8").strip()