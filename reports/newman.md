### Newman Report

Collection

Serverless Power Tuning API Tests

Description

CI smoke tests for Lambda + API Gateway + DynamoDB CRUD

Time

Fri Nov 07 2025 12:17:21 GMT+0000 (Coordinated Universal Time)

Exported with

Newman v6.2.1





**Total**

**Failed**

Iterations

1

0

Requests

3

0

Prerequest Scripts

0

0

Test Scripts

3

0

Assertions

5

0



Total run duration

1816ms

Total data received

1.17KB (approx)

Average response time

578ms



**Total Failures**

**0**

  

#### Requests

#### List Items

Method

GET

URL

<https://scvdhagu6i.execute-api.eu-west-2.amazonaws.com/prod/items>





Mean time per request

1158ms

  

Mean size per request

1.09KB

  



  

Total passed tests

1

Total failed tests

0

  



  

Status code

200

  



Tests

Name| Pass count| Fail count  
---|---|---  
List returns 200| 1| 0  
  
#### Create Item

Method

POST

URL

<https://scvdhagu6i.execute-api.eu-west-2.amazonaws.com/prod/items>





Mean time per request

296ms

  

Mean size per request

41B

  



  

Total passed tests

2

Total failed tests

0

  



  

Status code

201

  



Tests

Name| Pass count| Fail count  
---|---|---  
Create returns 201| 1| 0  
Created ID stored| 1| 0  
  
#### Get Item

Method

GET

URL

<https://scvdhagu6i.execute-api.eu-
west-2.amazonaws.com/prod/items/test-1762517841>





Mean time per request

280ms

  

Mean size per request

41B

  



  

Total passed tests

2

Total failed tests

0

  



  

Status code

200

  



Tests

Name| Pass count| Fail count  
---|---|---  
Get returns 200| 1| 0  
Item ID matches| 1| 0

