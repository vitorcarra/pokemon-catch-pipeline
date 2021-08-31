output "lambda_layer_arn" {
    value = aws_lambda_layer_version.pandas_layer.arn
}
