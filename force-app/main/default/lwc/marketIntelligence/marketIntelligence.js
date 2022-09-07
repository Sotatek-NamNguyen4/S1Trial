import getDepartmentPicklist from '@salesforce/apex/rpaDao.getDepartmentPicklist';
import getListRpa from '@salesforce/apex/rpaDao.getListRpa';
import getListRpaByPageNumber from '@salesforce/apex/rpaDao.getListRpaByPageNumber';
import { api, LightningElement, track, wire } from 'lwc';

const BTN_ACTIVE_CLASSES = 'slds-button slds-button_brand slds-button_middle';
const BTN_INACTIVE_CLASSES = 'slds-button slds-button_neutral slds-button_middle';
const CARD_VISIBLE_CLASSES = 'slideshow slds-show';
const CARD_HIDDEN_CLASSES = 'slideshow slds-hide';
const DOT_VISIBLE_CLASSES = 'dot active';
const DOT_HIDDEN_CLASSES = 'dot';
const DEFAULT_SLIDER_TIMER = 7000; // 7 sec

export default class MarketIntelligence extends LightningElement {

    // navbar
    @track listDept = [];
    @track currentDept = 'BSP';

    // carousel
    @track rpaNews = [];
    @track slideIndex = 1;
    @track timer;

    // pagination
    @track pageData = [];
    @track pagesArray = [];
    @track totalPages = 0;
    @track pageSize = 5;
    @track currentPage = 1;

    // get navbar data
    @wire (getDepartmentPicklist) deptPicklist ({error, data}) {
        // if (data) {
        //     console.log('picklist data: ', data);
        // }
        // if (error) {
        //     console.log('err: ', error);
        // }
    }

    // get carousel data
    @wire(getListRpa, { deptName: '$currentDept' }) 
    listRpa({error, data}) {
        if(data) {
            // console.log('data: ', data);
            this.rpaNews = data.map((item, index) => {
                return index === 0 ? {
                    ...item,
                    slideIndex: index + 1,
                    cardClasses: CARD_VISIBLE_CLASSES,
                    dotClasses: DOT_VISIBLE_CLASSES
                } : {
                    ...item,
                    slideIndex: index + 1,
                    cardClasses: CARD_HIDDEN_CLASSES,
                    dotClasses: DOT_HIDDEN_CLASSES
                }
            })
            // console.log('rpaNews: ', this.rpaNews);
        }
        if (error) {
            console.log('err: ', error);
        }
    }

    // get pagination data
    @wire(getListRpaByPageNumber, { pageNumber : '$currentPage', deptName: '$currentDept'})
    listTest ({error, data})  {
        // if(data) {
        //     console.log('paging data: ', data);
        // }
        // if (error) {
        //     console.log('err: ', error);
        // }
    } 

    async connectedCallback() {
        await this.switchDept(this.currentDept);
        await this.getListRpaByPageNumber(this.currentPage, this.currentDept);
        await this.renewInterval();
        console.log('check pageData: ', this.pageData);
    }

    /**
    *  Change navbar btn attribute
    *  @param currentDept name of department
    *  @return list departments with additional attribute
    **/
    switchDept(currentDept) {
        getDepartmentPicklist()
        .then(data => {
            this.listDept = data.map(item => {
                return currentDept == item ? {
                    value: item,
                    btnClasses: BTN_ACTIVE_CLASSES
                } : {
                    value: item,
                    btnClasses: BTN_INACTIVE_CLASSES
                }
            });
            this.getListRpaByPageNumber(1, currentDept);
            this.renewInterval();
        })
        .catch(error => {
            this.error = error;
        });

    }

    /**
    *  Call Apex Class to get List News by conditions
    *  @param pageNumber current page number
    *  @return list news and pagination data
    **/
    getListRpaByPageNumber(pageNumber, currentDept) {
        console.log('page: ', pageNumber);
        getListRpaByPageNumber({
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

    /**
    *  Change attribute of carousel items
    *  @param newsIndex index of carousel items
    *  @return list carousel items
    **/
    newsSelectionHandler(newsIndex) {
        if (newsIndex > this.rpaNews.length) {
            this.slideIndex = 1;
        } else {
            this.slideIndex = newsIndex;
        }
        this.rpaNews = this.rpaNews.map(item => {
            return this.slideIndex === item.slideIndex ? {
                ...item,
                cardClasses: CARD_VISIBLE_CLASSES,
                dotClasses: DOT_VISIBLE_CLASSES
            } : {
                ...item,
                cardClasses: CARD_HIDDEN_CLASSES,
                dotClasses: DOT_HIDDEN_CLASSES
            }
        });
        this.renewInterval();
    }

    // update current department value for query
    handleChangeDept(event) {
        this.currentDept = event.currentTarget.dataset.key;
        console.log('click on nav btn: ', this.currentDept);
        this.switchDept(this.currentDept);
    }

    // carousel handler
    newsSelectionHandler(newsIndex) {
        if (newsIndex > this.rpaNews.length) {
            this.slideIndex = 1;
        } else {
            this.slideIndex = newsIndex;
        }
        this.rpaNews = this.rpaNews.map(item => {
            return this.slideIndex === item.slideIndex ? {
                ...item,
                cardClasses: CARD_VISIBLE_CLASSES,
                dotClasses: DOT_VISIBLE_CLASSES
            } : {
                ...item,
                cardClasses: CARD_HIDDEN_CLASSES,
                dotClasses: DOT_HIDDEN_CLASSES
            }
        });
        this.renewInterval();
    }
    handleOnClickCarouselDot(event) {
        let newsIndex = Number(event.target.dataset.id);
        this.newsSelectionHandler(newsIndex);
    }
    renewInterval() {
        window.clearInterval(this.timer);
        this.timer = window.setInterval(() => {
            this.newsSelectionHandler(this.slideIndex + 1);
        }, Number(DEFAULT_SLIDER_TIMER))
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
        this.getListRpaByPageNumber(this.currentPage - 1, this.currentDept);
    }
    nextPageHandler() {
        this.getListRpaByPageNumber(this.currentPage + 1, this.currentDept);
    }
    handleOnClickPageButton(event) {
        this.currentPage = event.currentTarget.dataset.key;
        this.getListRpaByPageNumber(event.currentTarget.dataset.key, this.currentDept);
    }

}