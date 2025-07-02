resource "aws_api_gateway_rest_api" "affirmation_api" {
  name = "affirmation-api"
}

resource "aws_api_gateway_resource" "affirmation_resource" {
  rest_api_id = aws_api_gateway_rest_api.affirmation_api.id
  parent_id   = aws_api_gateway_rest_api.affirmation_api.root_resource_id
  path_part   = "say"
}

resource "aws_api_gateway_method" "get_method" {
  rest_api_id   = aws_api_gateway_rest_api.affirmation_api.id
  resource_id   = aws_api_gateway_resource.affirmation_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.affirmation_api.id
  resource_id             = aws_api_gateway_resource.affirmation_resource.id
  http_method             = aws_api_gateway_method.get_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.affirmation_lambda.invoke_arn
}

resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.affirmation_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.affirmation_api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on  = [aws_api_gateway_integration.lambda_integration]
  rest_api_id = aws_api_gateway_rest_api.affirmation_api.id
  stage_name  = "prod"
}
