# Data block to fetch the latest Ubuntu AMI
data "aws_ami" "imageami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# EC2 Instance resource
resource "aws_instance" "Event-management-app" {
  ami           = data.aws_ami.imageami.image_id
  instance_type = "t2.micro"
  key_name      = "Event_management"
  security_groups = [aws_security_group.Terraform_Firewall.name]
  tags = {
    Name = "Event-management"
  }
  user_data_replace_on_change = true
  user_data = <<EOF
#!/bin/bash
apt update && apt upgrade -y
apt install apache2 -y
mkdir -p /var/www/html/event_management
cat << EOT > /var/www/html/event_management/index.html

<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Event Management</title>
    <link rel="stylesheet" href="style.css" />
  </head>
  <body>
    <div class="container">
      <h1 class="title">Event Registration Form</h1>
      <form id="event-form" class="form">
        <label for="event_id">Event ID:</label>
        <input type="number" id="event_id" name="event_id" required />

        <label for="event_name">Event Name:</label>
        <input type="text" id="event_name" name="event_name" required />

        <label for="event_date">Event Date:</label>
        <input type="date" id="event_date" name="event_date" required />

        <button type="submit" class="btn">Register</button>
      </form>
      <div class="output">
        <p><strong>Response:</strong></p>
        <p id="response-message"></p>
      </div>
    </div>
    <script src="app.js"></script>
  </body>
</html>
EOT
cat <<EOT > /var/www/html/event_management/style.css
body {
    font-family: Arial, sans-serif;
    margin: 0;
    padding: 0;
    background: linear-gradient(120deg, #0dd6dd, #5ea7bd);
    height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
  }
  
  /* Container */
  .container {
    background: rgb(172, 230, 14);
    padding: 20px 40px;
    border-radius: 10px;
    box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
    text-align: center;
    width: 100%;
    max-width: 400px;
    animation: slideIn 1s ease-out;
  }
  
  /* Title */
  .title {
    font-size: 24px;
    color: #333;
    margin-bottom: 20px;
  }
  
  /* Form elements */
  .form label {
    font-weight: bold;
    color: #444;
    display: block;
    margin: 10px 0 5px;
  }
  
  .form input {
    width: 100%;
    padding: 10px;
    margin-bottom: 15px;
    border: 1px solid #141414;
    border-radius: 5px;
    font-size: 16px;
    transition: 0.3s ease;
  }
  
  .form input:focus {
    border-color: #ff6b6b;
    box-shadow: 0 0 5px rgba(255, 107, 107, 0.5);
    outline: none;
  }
  
  /* Button */
  .btn {
    background: #ff6b6b;
    color: white;
    border: none;
    padding: 10px 15px;
    border-radius: 5px;
    cursor: pointer;
    font-size: 16px;
    transition: transform 0.3s ease, background 0.3s ease;
  }
  
  .btn:hover {
    background: #ee5253;
    transform: translateY(-3px);
  }
  
  /* Output */
  .output {
    margin-top: 20px;
    color: #333;
  }
  
  /* Animations */
  @keyframes slideIn {
    from {
      transform: translateY(50px);
      opacity: 0;
    }
    to {
      transform: translateY(0);
      opacity: 1;
    }
  }
EOT

cat <<EOT > /var/www/html/event_management/app.js
const form = document.getElementById("event-form");
const responseMessage = document.getElementById("response-message");

// API Gateway Endpoint
const apiEndpoint = "${aws_apigatewayv2_stage.stage.invoke_url}/api/events" //add the api-endpoint link

// Event Listener for Form Submission
form.addEventListener("submit", async function (e) {
  e.preventDefault();

  // Get form data
  const eventID = e.target.event_id.value;
  const eventName = e.target.event_name.value;
  const eventDate = e.target.event_date.value;

   // Remove hyphens from event_date
   let formattedDate = eventDate.replace(/-/g, '');
   
  // Create request payload
  const payload = {
    eid: eventID,
    ename: eventName,
    edate: formattedDate,
  };

  try {
    // Make POST request to the API Gateway endpoint
    const response = await fetch(apiEndpoint, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(payload),
    });

    // Parse the response JSON
    const data = await response.json();
    // Display the response message
    if (response.ok) {
      responseMessage.innerHTML = "<span style='color: black;font-weight: bold;'>"+ data.message +"</span>";
    } else {
      responseMessage.innerHTML = "<span style='color:red;font-weight: bold;'>Error: "+ data.message +"</span>";
    }
  } catch (error) {
    // Handle network or unexpected errors
    responseMessage.innerHTML = "<span style='color: red;font-weight: bold;'>Error: "+ error.message +"</span>";
  }
});
EOT
systemctl restart apache2
EOF
}


# Variable for security group ports
variable "sg_port" {
  default = [80, 22]
}

# Security Group Resource
resource "aws_security_group" "Terraform_Firewall" {
  name = "Firewall"

  dynamic "ingress" {
    for_each = var.sg_port
    iterator = port
    content {
      cidr_blocks = ["0.0.0.0/0"]
      from_port   = port.value
      protocol    = "tcp"
      to_port     = port.value
    }
  }
  # Egress Rule for Security Group
egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}
}


