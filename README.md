# Car Inventory System – Serverless AWS Architecture

![Architecture Diagram](A_network_architecture_diagram_in_the_digital_illu.png)

## 📌 Overview

This project is a **Serverless Car Inventory System** built fully on AWS using modern cloud-native services. It allows users to:

* Add car listings
* Upload car images
* Update listings
* Delete listings
* View all available cars

All backend logic is powered by **AWS Lambda**, while car data and images are stored in **DynamoDB** and **S3** respectively.

---

## 🏗️ Architecture Components

### **1. Frontend (Website)**

A simple web interface (HTML/CSS/JS or any framework) that interacts with the backend via REST API.

### **2. Amazon API Gateway**

Acts as the entry point for the frontend. It routes HTTP requests to the appropriate Lambda functions.

### **3. AWS Lambda Functions**

These serverless functions handle all business logic:

* `CreateCarLambda`
* `ListCarsLambda`
* `GetCarLambda`
* `UpdateCarLambda`
* `DeleteCarLambda`
* `UploadImageLambda`

### **4. Amazon DynamoDB**

A NoSQL database used to store structured car data such as model, brand, year, price, and more.

### **5. Amazon S3**

Serves as the storage for car images. The `UploadImageLambda` generates presigned URLs for secure uploads.

### **6. Terraform**

Infrastructure-as-Code used to deploy and manage all AWS services in a repeatable, version-controlled manner.

---

## 📂 Folder Structure

```
project/
│── terraform/
│   ├── main.tf
│   ├── s3.tf
│   ├── lambdas.tf
│   ├── dynamodb.tf
│   └── api_gateway.tf
│
└── src/
    ├── create_car/handler.py
    ├── list_cars/handler.py
    ├── get_car/handler.py
    ├── update_car/handler.py
    ├── delete_car/handler.py
    └── upload_image/handler.py
```

---

## 🚀 Deployment Instructions

### **1. Initialize Terraform**

```
terraform init
```

### **2. Preview Changes**

```
terraform plan
```

### **3. Apply Infrastructure**

```
terraform apply
```

(Enter `yes` when prompted)

### **4. Retrieve Output Values**

Terraform will output:

* API endpoint
* DynamoDB table name
* S3 bucket name

### **5. Start Using the APIs**

Use Postman, curl, or your frontend to interact with your deployed API.

---

## 📝 API Endpoints

```
POST   /cars            → Create new car
GET    /cars            → List all cars
GET    /cars/{carId}    → Get car by ID
PUT    /cars/{carId}    → Update car
DELETE /cars/{carId}    → Delete car
POST   /cars/upload     → Get presigned S3 upload URL
```

---

## 📦 Future Enhancements

* Add user authentication via Amazon Cognito
* Add car search filters using DynamoDB GSI
* Add CloudFront + S3 static hosting for frontend
* Add CI/CD pipeline using GitHub Actions

---

## ❤️ Credits

Designed and implemented by Felix (Eminent Dev).

This README includes the official project architecture diagram and full system explanation.
