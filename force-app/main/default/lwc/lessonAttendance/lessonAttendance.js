import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getAttendances from '@salesforce/apex/LessonAttendanceController.getAttendances';
import updateAttendances from '@salesforce/apex/LessonAttendanceController.updateAttendances';

import ID_FIELD from '@salesforce/schema/StudentLessonAttendance__c.Id';
import ATTENDING_FIELD from '@salesforce/schema/StudentLessonAttendance__c.IsAttending__c';

const COLS = [
    {
        label: 'Student',
        fieldName: 'studentUrl',
        type: 'url',
        typeAttributes: { label: { fieldName: 'studentName' }, target: '_blank' }
    },
    {
        label: 'Group',
        fieldName: 'groupUrl',
        type: 'url',
        typeAttributes: { label: { fieldName: 'groupName' }, target: '_blank' }
    },
    { label: 'Attending', fieldName: 'IsAttending__c', type: 'boolean', editable: true }
];

export default class LessonAttendance extends LightningElement {

    @api recordId;
    columns = COLS;
    draftValues = [];
    
    @track isLoading = true;
    @track attendances;

    @wire(getAttendances, { lessonId: '$recordId' })
    wiredAttendances({ error, data }) {
        if(data) {
            this.isLoading = false;
            let studentUrl;
            let studentName;
            let groupUrl;
            let groupName;
            this.attendances = data.map(row => { 
                studentUrl = `/${row.Student__c}`;
                studentName = row.Student__r.Name;
                groupUrl = `/${row.StudentGroup__c}`
                groupName = row.StudentGroup__r.Name;
                return { ...row , studentUrl, studentName, groupUrl, groupName } 
            })
            if (this.attendances.length === 0) {
                this.attendances = undefined;
            }
        } else if(error) {
            this.isLoading = false;
            this.attendances = undefined;
        }
    }
    
    handleSave(event) {
        const recordInputs =  event.detail.draftValues.slice().map(draft => {
            return Object.assign({}, draft);
        });
        this.isLoading = true;
        updateAttendances({ data: JSON.stringify(recordInputs) }).then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Attendances updated',
                    variant: 'success'
                })
            );
            return refreshApex(this.attendances).then(() => {
                this.draftValues = [];
            });
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating or reloading attendances',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        }).finally(() => {
            this.isLoading = false;
        })
    }
}