#coding=utf8
from typing import Dict, List
from typing import Any, Union, Optional
import shutil
import os


def download_and_execute_setup(controller, url: str, path: str = '/home/user/init.sh'):
    """ Download a script from a remote url and execute it to setup the environment.
    @args:
        controller(desktop_env.controllers.SetupController): the controller object
        url(str): remote url to download the script
        path(str): the path to save the script on VM (default: '~/init.sh')
    """
    # download the script
    controller._download_setup([{'url': url, 'path': path}])
    # execute the script
    controller._execute_setup(command=f"chmod a+x {path}")
    controller._execute_setup(command=f"bash {path}")
    controller._execute_setup(command=f"rm -f {path}")
    controller._execute_setup(command=f"rm -rf  __MACOSX")
    return

def download_and_unzip_setup(controller, url: str, path: str = '/home/user/gold.zip'):
    """ Download a script from a remote url and execute it to setup the environment.
    @args:
        controller(desktop_env.controllers.SetupController): the controller object
        url(str): remote url to download the script
        path(str): the path to save the script on VM (default: '~/init.sh')
    """
    # download the script
    controller._download_setup([{'url': url, 'path': path}])
    # execute the script
    controller._execute_setup(command=f"chmod a+x {path}")
    controller._execute_setup(command=f"unzip {path}")
    controller._execute_setup(command=f"rm -rf {path}")
    controller._execute_setup(command=f"rm -rf  __MACOSX")
    # make all the files in this path executable for all users
    controller._execute_setup(command=f"chmod -R a+rwx .")
    return

def download_setup(controller, url: str, path: str = '/home/user/gold.zip'):
    """ Download a script from a remote url and execute it to setup the environment.
    @args:
        controller(desktop_env.controllers.SetupController): the controller object
        url(str): remote url to download the script
        path(str): the path to save the script on VM (default: '~/init.sh')
    """
    # download the script

    return



def copy_execute_setup(controller, url: str, path: str = '/home/user/init.sh'):
    mnt_dir = controller.mnt_dir
    work_dir = '/workspace'
    real_path = path.replace(work_dir, mnt_dir)
    os.makedirs(os.path.dirname(real_path), exist_ok=True)
    shutil.copy2(url, real_path)
    controller._execute_setup(command=f"chmod a+x {path}")
    controller._execute_setup(command=f"bash {path}")
    controller._execute_setup(command=f"rm -f {path}")
    controller._execute_setup(command=f"rm -rf  __MACOSX")
    return    


def copy_setup(controller, files: List[Dict[str, str]]):
    mnt_dir = controller.mnt_dir
    work_dir = '/workspace'
    
    for file in files:    
        url = file['url']
        v_path = file['path']
        path = v_path.replace(work_dir, mnt_dir)
        
        if os.path.isfile(url):
            os.makedirs(os.path.dirname(path), exist_ok=True)
            shutil.copy2(url, path)
        elif os.path.isdir(url):
            shutil.copytree(url, path, dirs_exist_ok=True)
        else:
            print(f"Warning: {url} is neither a file nor a directory.")
    return

def copy_all_subfiles_setup(controller, dirs: List[str]):

    mnt_dir = controller.mnt_dir
    for dir in dirs:
        if os.path.isfile(dir):
            print(f"Warning: {dir} is a file, not a directory. Copying the file to {mnt_dir}.")
            shutil.copy2(dir, mnt_dir)
        elif os.path.isdir(dir):
            print(f"Copying all files in {dir} to {mnt_dir}.")
            shutil.copytree(dir, mnt_dir, dirs_exist_ok=True)
        else:
            print(f"Warning: {dir} is neither a file nor a directory.")
    return