package main

import (
        "context"
        "encoding/json"
        "github.com/aws/aws-lambda-go/events"
        "github.com/aws/aws-lambda-go/lambda"
        "unsafe"
)

type (
        ReturnValues struct {
                Success         bool    `json:"success"`
                Code		    int		`json:"code"`
                Message         string  `json:"message,omitempty"`
                Payload		    string	`json:"payload"`
        }
)


func handler(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
        return successResponse(&ReturnValues{Success:true, Code:0, Message:"OK"})
}


func successResponse(msg *ReturnValues) (events.APIGatewayProxyResponse, error) {
        msg.Success = true
        hdr := map[string]string {
                "Access-Control-Allow-Origin": "*",
        }
        r, _ := json.Marshal(msg)
        resp := events.APIGatewayProxyResponse{StatusCode: 200, Headers: hdr, Body: *(*string)(unsafe.Pointer(&r))}
        return resp, nil
}

func errorResponse(status int, msg ReturnValues) (events.APIGatewayProxyResponse, error) {
        msg.Success = false
        //fmt.Printf("%+v\n", msg)
        hdr := map[string]string {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*",
        }
        r, _ := json.Marshal(msg)
        resp := events.APIGatewayProxyResponse{StatusCode: status, Headers: hdr, Body: *(*string)(unsafe.Pointer(&r))}
        return resp, nil
}


func main() {
        lambda.Start(handler)
}
