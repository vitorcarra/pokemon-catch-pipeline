resource "aws_lambda_layer_version" "pandas_layer" {
  filename   = "pandas_layer/pandas_layer.zip"
  layer_name = "${var.project_name}-pandas-numpy-layer"

  source_code_hash = filebase64sha256("pandas_layer/pandas_layer.zip")

  compatible_runtimes = ["python3.7"]
}
