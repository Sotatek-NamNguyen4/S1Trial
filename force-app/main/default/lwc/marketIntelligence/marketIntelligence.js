import { LightningElement, track, wire } from 'lwc';
import getDepartmentPicklist from '@salesforce/apex/RpaController.getDepartmentPicklist';
import getNewsPaginationData from '@salesforce/apex/RpaController.getNewsPaginationData';
import getRpasByKeyword from '@salesforce/apex/RpaDao.getRpasByKeyword';

const BTN_ACTIVE_CLASSES = 'slds-button slds-button_brand slds-button_middle';
const BTN_INACTIVE_CLASSES = 'slds-button slds-button_neutral slds-button_middle';
const columns = [
    { label: 'Title', fieldName: 'TitleURL__c' },
    { label: 'URL', fieldName: 'URL__c'},
    { label: 'Summary', fieldName: 'SummaryURL__c'},
    { label: 'Topic', fieldName: 'Topic__c'},
    { label: 'Industry', fieldName: 'Industry'},
    { label: 'Keyword', fieldName: 'Keyword__r'},
];

export default class MarketIntelligence extends LightningElement {

    // search input field
    @track keyword = '';
    @track isShowModal = false;
    @track searchData = [];
    @track columns = columns;

    // navbar
    @track listDept = [];
    @track currentDept = '';

    // pagination          
    @track pageData = [];
    @track pagesArray = [];
    @track totalPages = 0;
    @track pageSize = 10;
    @track currentPage = 1;

    // get navbar data
    @wire (getDepartmentPicklist)
    picklistDept ({error, data}) {
        if(data) {
            this.listDept = data.map(item => {
                return {
                    label: item,
                    btnClasses: BTN_INACTIVE_CLASSES,
                    value: item
                }
            })
            this.listDept.unshift({label: 'All', btnClasses: BTN_ACTIVE_CLASSES ,value: ''});
            console.log('check list dept: ', this.listDept);
        }
        if (error) {
            console.log('err: ', error);
        }
    }

    // get pagination data
    @wire(getNewsPaginationData, { pageNumber : '$currentPage', deptName: '$currentDept'})
    listTest ({error, data})  {
        if(data) {
            console.log('paging data: ', data);
        }
        if (error) {
            console.log('err: ', error);
        }
    } 

    async connectedCallback() {
        this.switchDept(this.currentDept);
    }

    /**
    *  Change navbar btn attribute
    *  @param currentDept name of department
    *  @return list departments with additional attribute
    **/
    switchDept(currentDept) {
        this.listDept = this.listDept.map(item => {
            return {
                label: item.label,
                btnClasses: currentDept == item.value ? BTN_ACTIVE_CLASSES : BTN_INACTIVE_CLASSES,
                value: item.value
            }
        })
        this.getListRpaByPageNumber(1, currentDept);
    }

    /**
    *  Call Apex Class to get List News by conditions
    *  @param pageNumber current page number
    *  @return list news and pagination data
    **/
    getListRpaByPageNumber(pageNumber, currentDept) {
        console.log('page: ', pageNumber);
        getNewsPaginationData({
            pageNumber: pageNumber,
            deptName: currentDept
        })
        .then(result => {
            console.log('log result: ', result);
            if (result) {
                this.pageData = result.listNews;
                this.totalPages = result.totalPages;
                this.currentPage = result.currentPage;
                this.currentDept = currentDept;
                this.pagesArray = result.pagesArray.map(item => {
                    return this.currentPage === item ? {
                        value: item,
                        btnClasses: BTN_ACTIVE_CLASSES
                    } : {
                        value: item,
                        btnClasses: BTN_INACTIVE_CLASSES
                    }
                });
            }
        })
        .catch(error => {
            this.error = error;
        });
    }

    searchChangeHandler(event) {
        this.keyword = event.target.value;
        console.log('current keyword value: ', this.keyword);
    }

    handleEnter(event) {
        console.log('press btn: ', event.key);
        if (event.keyCode === 13) {
            this.searchHandler();
        }
    }

    searchHandler() {
        getRpasByKeyword({keyword: this.keyword})
        .then(result => {
            this.searchData = result.map(item => {
                return {
                    TitleURL__c: item.TitleURL__c,
                    URL__c: item.URL__c,
                    SummaryURL__c: item.SummaryURL__c,
                    // TitleURL__c: item.TitleURL__c,
                    Industry: item.Customer_Card__r.Industry,
                    // TitleURL__c: item.TitleURL__c,
                }
            });
            console.log('searchData: ', JSON.stringify(this.searchData) );
            this.showModalBox();
        })
        .catch(error => {
            console.log(error);
        });
    }

    showModalBox() {  
        this.isShowModal = true;
    }

    hideModalBox() {  
        this.isShowModal = false;
    }

    get isDisableSearchBtn() {
        return this.keyword == '';
    }
    
    // update current department value for query
    handleChangeDept(event) {
        this.currentDept = event.currentTarget.dataset.key;
        console.log('click on nav btn: ', this.currentDept);
        this.switchDept(this.currentDept);
    }

    // pagination button condition
    get isDisablePrevBtn() {
        return this.currentPage === 1;
    }
    get isDisableNextBtn() {
        return this.currentPage === this.totalPages || this.totalPages === 0;
    }

    // pagination button handler
    prevPageHandler() {
        this.scrollOnClick();
        this.getListRpaByPageNumber(this.currentPage - 1, this.currentDept);
    }
    nextPageHandler() {
        this.scrollOnClick();
        this.getListRpaByPageNumber(this.currentPage + 1, this.currentDept);
    }
    handleOnClickPageButton(event) {
        this.scrollOnClick();
        this.currentPage = event.currentTarget.dataset.key;
        this.getListRpaByPageNumber(event.currentTarget.dataset.key, this.currentDept);
    }
    scrollOnClick() {
        window.scrollTo({
            top: 0,
            behavior: 'smooth',
        });
    }
}