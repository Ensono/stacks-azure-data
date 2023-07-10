import jinja2
import yaml

with open("../config.yaml", "r") as file:
    config = yaml.safe_load(file)

environment = jinja2.Environment()
with open("adf_pipelines.tf.template", "r") as file:
    content = file.read()

template = environment.from_string(content)
print(template.render(config))
