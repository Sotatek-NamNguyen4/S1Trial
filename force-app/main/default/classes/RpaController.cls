public with sharing class RpaController {

    static final Integer PAGE_SIZE = 10;

    @AuraEnabled(cacheable=true)
    public static List<String> getDepartmentPicklist(){
        try {
            List<String> picklistValue = new List<String>();
            Schema.DescribeFieldResult objFieldDescribe = Account.Department__c.getDescribe();
            List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();
            for (Schema.PicklistEntry objPickList : lstPickListValues) {
                picklistValue.add(objPickList.getValue());
            }
            return picklistValue;
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            throw new DmlException('err: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static NewsPaginationWrapper getNewsPaginationData(Integer pageNumber, String deptName) {
        try {
            NewsPaginationWrapper wrapper = new NewsPaginationWrapper();
            List<Integer> pages = new List<Integer>();
            List<RPA__c> data = RpaDao.getRpasByPageNumberAndDept(pageNumber, deptName, PAGE_SIZE);
            Integer totalPagesCal = (Math.ceil(RpaDao.getRpasCountByDept(deptName)/ PAGE_SIZE)).intValue();
            wrapper.listNews = data;
            wrapper.totalPages = totalPagesCal;
            wrapper.currentPage = pageNumber; 
            if (totalPagesCal > 9) {
                if (pageNumber > 3) {
                    switch on (totalPagesCal - pageNumber) {
                        when 0 {
                            for (Integer i = (pageNumber - 8); i <= pageNumber; i++) {
                                pages.add(i);
                            }
                        }
                        when 1 {
                            for (Integer i = (pageNumber - 7); i <= wrapper.totalPages; i++) {
                                pages.add(i);
                            }
                        }
                        when else {
                            Integer pageLim = (pageNumber + 4) >= wrapper.totalPages ? wrapper.totalPages : (pageNumber + 4);
                            for (Integer i = (pageNumber - 4); i <= pageLim; i++) {
                                pages.add(i);
                            }
                        }
                    }
                } else {
                    for (Integer i = 1; i <= 9; i++) {
                        pages.add(i);
                    }
                }  
            } else {
                for (Integer i = 1; i <= wrapper.totalPages; i++) {
                    pages.add(i);
                }
            }
            wrapper.pagesArray = pages;
            return wrapper;
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            throw new DmlException('err: ' + e.getMessage());
        }

        
    }

    public class NewsPaginationWrapper {
        @AuraEnabled public List<RPA__c> listNews;
        @AuraEnabled public Integer totalPages;
        @AuraEnabled public Integer currentPage;
        @AuraEnabled public List<Integer> pagesArray;
    }
}
