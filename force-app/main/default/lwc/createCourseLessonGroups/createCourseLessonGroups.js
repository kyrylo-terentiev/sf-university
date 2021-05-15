import { api, wire, track, LightningElement } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { NavigationMixin } from 'lightning/navigation';

import getAvailableGroupsForLesson from '@salesforce/apex/CreateCourseLessonController.getAvailableGroupsForLesson';
import getAttendingGroupsForLesson from '@salesforce/apex/CreateCourseLessonController.getAttendingGroupsForLesson';
import addGroupsForLesson from '@salesforce/apex/CreateCourseLessonController.addGroupsForLesson';

import NAME_FIELD from '@salesforce/schema/Lesson__c.Name';

export default class CreateCourseLessonGroups extends NavigationMixin(LightningElement) {

    @api lessonId;

    @track error;
    @track isLoading = true;

    @track availableGroups = [];
    @track attendingGroups = [];
    selectedOptions;

    @wire(getRecord, { recordId: '$lessonId', fields: [ NAME_FIELD ] })
    lesson;

    @wire(getAvailableGroupsForLesson, { lessonId: '$lessonId' })
    avalaibleGroupsMap({ error, data }) {
        if (error) {
            this.isLoading = false;
            this.error = 'Unknown error';
            if (Array.isArray(error.body)) {
                this.error = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                this.error = error.body.message;
            }
        } else if (data) {
            this.isLoading = false;
            this.error = undefined;
            this.availableGroups = Object.keys(data).map(key => ({ label: key, value: data[key] }));
        }
    }

    @wire(getAttendingGroupsForLesson, { lessonId: '$lessonId' })
    attendingGroupsMap({ error, data }) {
        if (error) {
            this.isLoading = false;
            this.error = 'Unknown error';
            if (Array.isArray(error.body)) {
                this.error = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                this.error = error.body.message;
            }
        } else if (data) {
            this.isLoading = false;
            this.error = undefined;
            this.attendingGroups = Object.keys(data).map(key => ({ label: key, value: data[key] }));
        }
    }

    handleGroupChange(event) {
        this.error = undefined;
        this.selectedOptions = event.detail.value;
        console.log(`Options selected: ${this.selectedOptions}`);
    }

    @api
    handleSave() {
        if (this.selectedOptions) {
            this.isLoading = true;
            addGroupsForLesson({ lessonId: this.lessonId, groupIds: this.selectedOptions })
            .then((result) => {
                this.isLoading = false;
                this[NavigationMixin.GenerateUrl]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.lessonId,
                        actionName: 'view',
                    },
                }).then(url => {
                    const lessonName = getFieldValue(this.lesson.data, NAME_FIELD);
                    const groupNum = this.selectedOptions.length;
                    const event = new ShowToastEvent({
                        'title': 'Success!',
                        'variant': 'success',
                        'message': 'Lesson {0} created with {1} groups attending',
                        'messageData': [
                            {
                                url,
                                'label': lessonName
                            },
                            groupNum.toString()
                        ]
                    });
                    this.dispatchEvent(event);
                });
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.lessonId,
                        objectApiName: 'Lesson__c',
                        actionName: 'view',
                    },
                });
            })
            .catch((error) => {
                this.isLoading = false;
                this.error = error.message;
            });
        } else {
            this.error = 'Please select at least one group to attend the lesson';
        }
    }
}