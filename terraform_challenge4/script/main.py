#import functions_framework
import json
import requests


#@functions_framework.http
def hello_http(request):
    """HTTP Cloud Function.
    Args:
        request (flask.Request): The request object.
        <https://flask.palletsprojects.com/en/1.1.x/api/#incoming-request-data>
    Returns:
        The response text, or any set of values that can be turned into a
        Response object using `make_response`
        <https://flask.palletsprojects.com/en/1.1.x/api/#flask.make_response>.
    """
    request_json = request.get_json(silent=True)
    print(request_json)

    response_dict = {"flag4": "You found flag 4!", "response": ""}


    if request_json and 'url' in request_json:
        url = request_json['url']
    else:
        print("no url found")
        response_dict["response"] = "invalid input"
        return json.dumps(response_dict)

#    metadata = requests.get("http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token", headers={"Metadata-Flavor": "Google"})
# 
    if (url.startswith("http://") or url.startswith("https://")):
        response = requests.get(url, headers={"Metadata-Flavor": "Google"})
        response_dict["response"] = response.text
        return json.dumps(response_dict)

    response_dict["response"] = "invalid input"
    return json.dumps(response_dict)

