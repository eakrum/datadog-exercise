import time
import os
import requests

# simple agent to poll the api and create todos on the backend
def run_agent():
    api_endpoint = os.getenv('API_ENDPOINT')
    while True:
        t = time.localtime()
        current_time = time.strftime("%H:%M:%S", t)
        data = {'nametodo': "new todo at " + current_time,
            'is_complete': 'false',
        }
        res = requests.post(api_endpoint + '/api/addTodo', data=data)
        res2 = requests.get(api_endpoint + '/api/getTodos')
        print(res2.json())
        time.sleep(20)


if __name__ == '__main__':
    run_agent()

