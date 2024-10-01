from datetime import datetime
import json
import requests


def compute_engine_monitoring(request):
    """HTTP Cloud Function.
    Heartbeat function monitoring compute engines
    Dev version - Work in progress
    """
    request_json = request.get_json(silent=True)

    response_dict = {}

    if request_json and "metadata" in request_json:
        metadata = request_json["metadata"]
        # for IAM debugging purposes to check the functions service account - security recommended to remove this afterwards
        metadata_response = requests.get(
            f"http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/{metadata}",
            headers={"Metadata-Flavor": "Google"},
        )
        response_dict["function_account"] = metadata_response.text
        if metadata == "token":
            response_dict["flag4"] = "You found flag 4!"

    # compute engine monitoring
    response_dict["compute_engine_heartbeat"] = (
        f"compute engine was running at {datetime.today().strftime('%Y-%m-%d %H:%M:%S')}"
    )

    return json.dumps(response_dict)
