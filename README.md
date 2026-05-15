# Acme App - Agentforce Service Manager

[![Salesforce](https://img.shields.io/badge/Salesforce-Project-blue)](https://www.salesforce.com)
[![Agentforce](https://img.shields.io/badge/AI-Agentforce-green)](https://www.salesforce.com/products/einstein/)

**Acme App** is a high-performance Salesforce solution designed to streamline technical support. It integrates **Agentforce (Einstein Agents)** to analyze complex issue descriptions and automatically suggest precision resolution notes for support agents.

---

## 📺 Demo Video
> [!TIP]
> Click the badge below to see Acme App's AI reasoning and reactive interface in action.

https://github.com/user-attachments/assets/1c226efa-a87a-42dd-adb9-42b7af416db9

[![Watch the demo](https://img.shields.io/badge/Video-Demo_Preview-red?style=for-the-badge&logo=youtube)](https://youtu.be/fYYXQiQ8UV8)

---

## 🏗️ System Architecture



The Acme App architecture is built on a decoupled N-tier pattern to ensure strict separation of concerns and system stability:

1.  **Presentation Layer (LWC):** A reactive UI (`serviceRequestForm`) that manages user input and displays AI suggestions with real-time feedback.
2.  **Controller Layer (Apex):** `ServiceRequestController.cls` serves as the secure entry point, orchestrating data flow and AI proxy execution.
3.  **Service Layer (Apex):** `ServiceRequestService.cls` encapsulates the core business logic and database persistence (DML).
4.  **Data Transfer Layer (DTO):** `ServiceRequestDTO.cls` standardizes the data contract between the UI and the server, protecting the application from schema changes.
5.  **Orchestration Layer (Flow):** `Agentforce_Service_Proxy.flow` acts as a secure "AI Gateway" to invoke the Generative AI Agent.

<img width="1024" height="559" alt="image" src="https://github.com/user-attachments/assets/4e16b1db-d98f-4ebf-ac88-c6bbdaaf1b4c" />

---

## 🤖 AI Integration Flow

1.  **Input:** User provides a technical issue description in the Acme App interface.
2.  **Request:** Upon field exit (`onblur`), the LWC triggers a request to the Apex Controller.
3.  **Reasoning:** The Controller starts the Flow Proxy, which sends the input to the **Technical Support Agent**.
4.  **Processing:** Agentforce analyzes the text and generates a suggested resolution.
5.  **Response:** The AI's output is cleaned and returned to the LWC, automatically populating the resolution notes for final review.

---

## 🧪 Testing & Quality Strategy

Acme App is built with a "Test-First" mentality to ensure 100% reliable deployments.

<img width="370" height="149" alt="image" src="https://github.com/user-attachments/assets/96494acd-23d3-49f6-968f-e829ac603eca" />


* **AI Mocking Framework:** We use `Test.isRunningTest()` within the controller to simulate AI responses. This allows the test suite to validate the entire application flow without consuming AI credits or requiring live agent connectivity.
* **Unit Test Suite:** Comprehensive tests cover DTO transformations, Service Layer validations, and error handling for the AI proxy.

**Execute the test suite:**
```bash
sf apex run test -n ServiceRequestControllerTest,ServiceRequestServiceTest --result-format human
