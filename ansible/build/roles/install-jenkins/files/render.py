#!/usr/bin/env python3
import json
import sys

import jinja2

CONFIG_PATH = "/etc/jenkins-config.json"
ENVIRONMENT_PATH = "/etc/environment.json"


def load_json(path):
    with open(path) as f:
        return json.load(f)


def build_context(config_path, environment_path):
    data = load_json(config_path)
    data["environment"] = load_json(environment_path)
    data.setdefault("services", {})
    data.setdefault("env", {})

    env = jinja2.Environment(
        loader=jinja2.FileSystemLoader(searchpath="/"),
        trim_blocks=True,
        lstrip_blocks=True,
        keep_trailing_newline=True,
    )

    value_env = jinja2.Environment(
        variable_start_string="<<",
        variable_end_string=">>",
    )

    data["env"] = {
        key: value_env.from_string(str(value)).render(data)
        for key, value in data["env"].items()
    }
    return env, data


def main():
    template_path = sys.argv[1]
    output_path = sys.argv[2]
    config_path = sys.argv[3] if len(sys.argv) > 3 else CONFIG_PATH
    environment_path = sys.argv[4] if len(sys.argv) > 4 else ENVIRONMENT_PATH

    env, data = build_context(config_path, environment_path)
    template = env.get_template(template_path)

    with open(output_path, "w") as f:
        f.write(template.render(data))


if __name__ == "__main__":
    main()
