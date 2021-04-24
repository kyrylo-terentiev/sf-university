import { api, wire, track, LightningElement } from 'lwc';
import getAvailableGroupsForLesson from '@salesforce/apex/CreateCourseLessonController.getAvailableGroupsForLesson';

export default class CreateCourseLessonGroups extends LightningElement {

    @api lessonId;

    @track error;
    @track isLoading = true;

    @track availableGroups = [];

    @track attendingGroups = [];

    @wire(getAvailableGroupsForLesson, { lessonId: '$lessonId' })
    avalableGroupsMap({error, data}) {
        if (error) {
            this.isLoading = false;
            this.error = 'Unknown error';
            if (Array.isArray(error.body)) {
                this.error = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                this.error = error.body.message;
            }
            this.availableGroups = undefined;
        } else if (data) {
            this.isLoading = false;
            this.availableGroups = Object.keys(data).map(key => ({ label: key, value: data[key] }));
        }
    }

    

    handleGroupChange(event) {
        const selectedOptionsList = event.detail.value;
        console.log(`Options selected: ${selectedOptionsList}`);
    }

    @api
    handleSave() {
        console.log('save groups');
    }
}