import requests
import os
import json
import sys
import concurrent.futures
from datetime import datetime


def make_api_request(api_url: str) -> object:
    """
    Makes a request to an API and returns the response.

    Parameters:
        api_url (str): The URL of the API to make a request to.

    Returns:
        response (requests.models.Response): The response from the API.

    Raises:
        HTTPError: If the request was unsuccessful.
    """
    # Request data from the API
    print(f"Sending request to {api_url}...")
    response = requests.get(api_url, timeout=10)

    # Raise an exception if the request was unsuccessful
    response.raise_for_status()

    return response


def extract_api_data(api_url: str) -> list[dict]:
    """
    Retrieves all data from the given API, across all pages of results.

    Parameters:
        api_url (str): The URL of the API to make a request to.

    Returns:
        all_data (List[dict]): The data retrieved from the API, as a list of dictionaries.

    Raises:
        requests.exceptions.RequestException: For issues like network failure, invalid URL, etc.
        requests.exceptions.HTTPError: When an HTTP error occurs.
        requests.exceptions.ConnectionError: When a network problem occurs.
        requests.exceptions.Timeout: When a request times out.
    """
    all_data = []

    # Initialize a counter for the number of items retrieved
    items_retrieved = 0

    # Loop until all pages have been retrieved
    while api_url is not None:
        try:
            response = make_api_request(api_url)
        except requests.exceptions.RequestException as err:
            print("OOps: Something Else Happened", err)
            break
        except requests.exceptions.HTTPError as errh:
            print("Http Error:", errh)
            break
        except requests.exceptions.ConnectionError as errc:
            print("Error Connecting:", errc)
            break
        except requests.exceptions.Timeout as errt:
            print("Timeout Error:", errt)
            break
        else:
            # Add data to all_data list
            data = response.json()["value"]
            all_data.extend(data)

            # Print out the number of items retrieved
            items_retrieved += len(data)
            print(f"Retrieved {items_retrieved} items so far...")

            # Update the API URL for the next iteration
            api_url = response.json().get("odata.nextLink", None)

    return all_data


def construct_file_path(base_file_name: str, file_type: str = "json", is_timestamp_file: bool = False) -> str:
    """
    Constructs a file path based on a base file name, file type and a flag indicating if it's a timestamp file.
    The constructed path includes the current date and is relative to a 'data/raw' directory one level up from the script's directory.

    Parameters:
        base_file_name (str): The base name for the file.
        file_type (str): The type of the file (default is "json").
        is_timestamp_file (bool): Flag indicating whether this is a timestamp file (default is False).

    Returns:
        file_path (str): The full path to the file.
    """
    # Get the current date and format it as a string
    date_string = datetime.now().strftime("%Y%m%d")
    base_file_name_lower = base_file_name.lower()

    # Get the directory that this script is in
    script_dir = os.path.dirname(os.path.abspath(__file__))

    # Go up one level and then into the 'data' directory
    data_dir = os.path.join(script_dir, "..", f"data/raw/{base_file_name_lower}")

    if is_timestamp_file:
        # Create a filename for the timestamp file
        filename = f"last_run_{base_file_name_lower}.json"
    else:
        # Create a filename with the date
        filename = f"{base_file_name_lower}_{date_string}.{file_type}"

    # Get the full path to the file
    file_path = os.path.join(data_dir, filename)

    # Check if directory exists, create it if it doesn't
    os.makedirs(os.path.dirname(file_path), exist_ok=True)

    return file_path


def save_data(data: any, file_path: str) -> None:
    """
    Saves the provided data into a file at the given path. Data is saved in JSON format.

    Parameters:
        data (Any): The data to be saved. Can be of any type that is serializable by json.dump().
        file_path (str): The path of the file where data is to be saved.

    Returns:
        None

    Raises:
        IOError: If there is an I/O error while writing to the file.
        Exception: If there is an unexpected error.
    """
    try:
        # Save the data to a file
        with open(file_path, "w", encoding='utf8') as file:
            json.dump(data, file, ensure_ascii=False)

        print(f"Data saved to {file_path}")

    except IOError as e:
        print(f"I/O error({e.errno}): {e.strerror}")
    except:  # handle other exceptions such as attribute errors
        print("Unexpected error:", sys.exc_info()[0])


def retrieve_data(api_url: str, base_file_name: str) -> None:
    """
    Retrieves data from an API, saves it to a file, and saves the timestamp of the run.

    Parameters:
        api_url (str): The URL of the API to retrieve data from.
        base_file_name (str): The base name for the files where data and timestamp will be saved.

    Returns:
        None
    """
    # Retrieve data from the API
    all_data = extract_api_data(api_url)
    file_path = construct_file_path(base_file_name)
    save_data(all_data, file_path)

    # Save the timestamp of the last run
    file_path_last_run = construct_file_path(base_file_name, is_timestamp_file=True)
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    save_data({"last_run": timestamp}, file_path_last_run)


# add python main file check
if __name__ == "__main__":
    # Define the API URLs to retrieve data from
    file_names = [
        "Afstemning",
        "Afstemningstype",
        "Aktør",
        "Aktørtype",
        "Møde",
        "Mødestatus",
        "Mødetype",
        "Periode",
        "Sag",
        "Sagstrin",
        "SagstrinAktør",
        "Sagstrinsstatus",
        "Sagstrinstype",
        "Sagskategori",
        "Sagsstatus",
        "Sagstype",
        "Stemme",
        "Stemmetype"
    ]
    with concurrent.futures.ThreadPoolExecutor(max_workers=5) as executor:
        for file_name in file_names:
            api_url = f"https://oda.ft.dk/api/{file_name}?$inlinecount=allpages"

            # Submit a new task to the executor
            executor.submit(retrieve_data, api_url, file_name)
