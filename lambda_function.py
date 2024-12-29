import boto3
import json
#initalize DynamoDB resource outside the function as a best practice
dynamodb=boto3.resource("dynamodb")
event_table=dynamodb.Table('event-management')

def lambda_handler(event, context):
    try:
        # Print only relevant information to reduce log noise
        print(f"Incoming request: {event.get('body')}")

        # Safely parse the body as JSON
        event_data = json.loads(event.get("body", "{}"))
        
         # Extract and sanitize values
        receivedEventID = int(event_data["eid"])
        receivedEventDate = int(event_data["edate"].strip())
        receivedEventName = event_data["ename"].strip()

        # Add the item to the DynamoDB table
        event_table.put_item(
            Item={
                "event_id": receivedEventID,
                "event_name": receivedEventName,
                "event_date": receivedEventDate,
            }
        )
         # Return success response
        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Event added successfully"})
        }

    except ValueError as ve:
        # Handle conversion errors and invalid inputs
        print(f"Value error: {str(ve)}")
        return {
            "statusCode": 400,
            "body": json.dumps({"message": "Invalid input", "error": str(ve)})
        }
        
    except Exception as e:
        # Log unexpected errors
        print(f"Unexpected error: {str(e)}")
        return {
            "statusCode": 500,
            "body": json.dumps({"message": "An unexpected error occurred", "error": str(e)})
        }

        
        