import json

with open("/results/raid_status.txt") as f:
    data = f.read()
drive_status_all = data.split("--\n")
response = []
for drive_status in drive_status_all:
    drive = drive_status.split("======================")[0].split("State")[0].strip("Drive").strip()
    drive_status = drive_status.split("======================")[1]

    drive_response: dict = {"drive": drive}
    for line in drive_status.split("\n"):
        if line.strip():
            parts = line.split("=")
            key = parts[0].strip().lower().replace(" ", "_").replace(".", "")
            value = parts[1].strip().lower()
            if value == "yes" or value == "no":
                value = True if value == "yes" else False
            elif value.isdigit():
                value = int(value)
            drive_response[key] = value

    response.append(drive_response)

with open("/tmp/drive_status.json", "w") as f:
    f.write(json.dumps(response))
