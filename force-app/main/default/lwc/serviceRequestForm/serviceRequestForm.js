import { LightningElement, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import askAgentforce from '@salesforce/apex/ServiceRequestController.askAgentforce';
import createRequest from '@salesforce/apex/ServiceRequestController.createRequest';
import getRecentRequests from '@salesforce/apex/ServiceRequestController.getRecentRequests';

// Configuration for the datatable columns
const COLUMNS = [
    { label: 'Name', fieldName: 'name', type: 'text' },
    { label: 'Email', fieldName: 'email', type: 'email' },
    { label: 'Status', fieldName: 'status', type: 'text' },
    { label: 'Priority', fieldName: 'priority', type: 'text' },
    { 
        type: 'button', 
        typeAttributes: { 
            label: 'Edit', 
            name: 'edit', 
            variant: 'brand-outline',
            iconName: 'utility:edit'
        } 
    }
];

export default class ServiceRequestManager extends LightningElement {
    // Form data properties
    @track email = '';
    @track description = '';
    @track resolutionNotes = '';
    @track citations = '';
    @track priority = 'Medium';
    
    // UI State management
    @track isAiLoading = false;
    @track isLoading = false;
    @track recordId;
    @track error;

    // Table and Modal properties
    @track columns = COLUMNS;
    @track isModalOpen = false;
    @track selectedRecord = {};
    
    wiredRequestsResult;
    recentRequests = [];

    // Options for the priority dropdown
    priorityOptions = [
        { label: 'High', value: 'High' },
        { label: 'Medium', value: 'Medium' },
        { label: 'Low', value: 'Low' }
    ];

    // Automatically fetch recent requests using Wire Service
    @wire(getRecentRequests)
    wiredRequests(result) {
        this.wiredRequestsResult = result;
        if (result.data) {
            this.recentRequests = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = 'Error loading recent requests';
            this.recentRequests = [];
        }
    }

    // Capture user input from the form
    handleEmail(e) { this.email = e.target.value; }
    handleDescription(e) { this.description = e.target.value; }
    handleResolutionNotes(e) { this.resolutionNotes = e.target.value; }
    handlePriority(e) { this.priority = e.target.value; }

    // Trigger AI Agent when the user finishes typing the description
    async handleDescriptionBlur() {
        if (!this.description || this.description.length < 15) return;
        
        this.isAiLoading = true;
        this.error = null;


        try {
            // Call Apex to get AI-generated resolution notes
            const result = await askAgentforce({ userMessage: this.description });
            this.processAgentResponse(result);
        } catch (err) {
            this.error = 'Agentforce Connection Error: ' + (err.body ? err.body.message : err.message);
        } finally {
            this.isAiLoading = false;
        }
    }

    // Assign AI response to resolution notes
    processAgentResponse(rawResponse) {  
        if (rawResponse) {       
            this.resolutionNotes = rawResponse;
        } else {
            this.resolutionNotes = 'No response received from the agent.';
        }
    }

    // Create a new Service Request record in Salesforce
    async handleSubmit() {
        if (!this.description || !this.email) {
            this.showToast('Error', 'Description and Email are required', 'error');
            return;
        }

        this.isLoading = true;
        try {
            const result = await createRequest({ 
                requestDTO: { 
                    email: this.email, 
                    description: this.description, 
                    resolutionNotes: this.resolutionNotes, 
                    priority: this.priority 
                } 
            });
            this.recordId = result.id;
            this.showToast('Success', 'Request created successfully', 'success');
            
            // Refresh table data and clear the form
            await refreshApex(this.wiredRequestsResult);
            this.resetForm();
        } catch (err) {
            this.error = err.body ? err.body.message : err.message;
        } finally {
            this.isLoading = false;
        }
    }

    // Clear all form fields
    resetForm() {
        this.email = '';
        this.description = '';
        this.resolutionNotes = '';
    
        this.priority = 'Medium';
    }

    // Handle button clicks within the datatable
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName === 'edit') {
            this.selectedRecord = row;
            this.isModalOpen = true;
        }
    }

    // Close the edit modal
    closeModal() {
        this.isModalOpen = false;
    }

    // Handle successful record updates from the modal
    handleEditSuccess() {
        this.isModalOpen = false;
        this.showToast('Updated', 'Record updated successfully', 'success');
        refreshApex(this.wiredRequestsResult);
    }

    // Standard utility to show notification toasts
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}