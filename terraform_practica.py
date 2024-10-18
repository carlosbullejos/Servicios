from python_terraform import *

tf = Terraform(working_dir='terraform/vpcs')
tf.init()
tf.plan()
tf.apply(skip_plan=True)