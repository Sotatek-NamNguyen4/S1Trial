public with sharing class rpaDao {

    static final Integer PAGE_SIZE = 5;

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
    public static List<RPA__c> getListRpa(String deptName){
        try {
            Date lastTwoWeek = System.Today() - 14;  
            List<RPA__c> listRpa = [SELECT Name, TitleURL__c, SummaryURL__c, ImageURL__c, 
                                    Customer_Card__c, CreatedDate__c, Customer_Card__r.Department__c 
                                    FROM RPA__c 
                                    WHERE CreatedDate__c >= :lastTwoWeek 
                                    AND Customer_Card__r.Department__c LIKE :deptName
                                    ORDER BY CreatedDate__c DESC LIMIT :PAGE_SIZE];
            return listRpa;
        }
        catch (Exception e) {
            System.debug(e.getStackTraceString());
            throw new DmlException('err: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static NewsPaginationWrapper getListRpaByPageNumber(Integer pageNumber, String deptName){
        try {
            NewsPaginationWrapper wrapper = new NewsPaginationWrapper();
            System.debug('dept param: ' + deptName);
            List<Integer> pages = new List<Integer>();
            Integer offset = ((pageNumber - 1) * PAGE_SIZE) + 5;
            String queryCount = 'SElECT COUNT() FROM RPA__c WHERE Customer_Card__r.Department__c LIKE :deptName OFFSET 5';
            String query = 'SELECT Id, Name, TitleURL__c, SummaryURL__c, ImageURL__c, CreatedDate__c,  Customer_Card__r.Department__c ' + 
                            'FROM RPA__c WHERE Customer_Card__r.Department__c LIKE :deptName ' +
                            'ORDER BY CreatedDate__c DESC LIMIT 5 OFFSET :offset';
            System.debug('query: ' + query);
            List<RPA__c> listRpa = Database.query(query);
            Integer totalRecords = Database.countQuery(queryCount);
            System.debug('list: ' + listRpa);
            System.debug('count: ' + totalRecords);
            wrapper.listNews = listRpa;
            wrapper.currentPage = pageNumber;
            wrapper.totalPages = (Math.ceil(totalRecords / PAGE_SIZE)).intValue();
            for (Integer i = 1; i <= wrapper.totalPages; i++) {
                pages.add(i);
            }
            wrapper.pagesArray = pages;
            return wrapper;
        }
         catch (Exception e) {
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