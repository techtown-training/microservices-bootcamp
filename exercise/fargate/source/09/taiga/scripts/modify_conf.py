import os
import json

# Manipulates the given attribute in the give conf.json file
def modifyJSONFile(json_file_path, field_name, field_value, removeValue=False):
    if not os.path.isfile(json_file_path):
        print("Could not finde file {}".format(json_file_path))
        return

    with open(json_file_path, "r") as json_file:
        data = json.load(json_file)

    if not field_name in data or not isinstance(data, dict):
        print("Could not find field {}".format(field_name))
        return


    # check if its an array
    if isinstance(data[field_name],list):
         # check if value already exisits
        if field_value in data[field_name]:
            # we want to add the value
            if removeValue:
                data[field_name].remove(field_value)
            else:
                print("Value {0} already configured for field {1}".format(field_value, field_name))
                return
        else:
            data[field_name].append(field_value)
            print("Added value {0} to array field {1}".format(field_value, field_name))

    # its a simple key value but not an array
    else:
        if field_value == data[field_name]:
            # we want to add the value
            if removeValue:
                data[field_name] = None
            else:
                print("Value {0} already configured for field {1}".format(field_value, field_name))
                return
        else:
            data[field_name] = field_value
            print("Configured value {0} for field {1}".format(field_value, field_name))


    # write out resilt
    with open(json_file_path, "w") as jsonFile:
        json.dump(data, jsonFile, sort_keys=True,indent=4)