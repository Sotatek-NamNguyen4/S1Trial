/**
 * class Dao of RPA__c
 *
 * @author nam.nguyen4
 */
public with sharing class RpaDao {
    /**
     * get number of news depends on deptName
     * @param deptName department value
     * @return Integer number of news
     */
    public static Integer getRpasCountByDept(String deptName){
        try {
            String query = 'SElECT COUNT() FROM RPA__c ';
            if (String.isNotEmpty(deptName)) {
                query += 'WHERE Customer_Card__r.Department__c LIKE :deptName';
            }
            Integer countNews = Database.countQuery(String.escapeSingleQuotes(query));
            return countNews;
        }
        catch (Exception e) {
            System.debug(e.getStackTraceString());
            throw new DmlException('err: ' + e.getMessage());
        }
    }

    /**
     * get List records of RPA and pagination data
     * @param deptName department value
     * @param pageNumber chosen page number
     * @return pagination data
     */
    public static List<RPA__c> getRpasByPageNumberAndDept(Integer pageNumber, String deptName, Integer pageSize){
        try {
            Integer offset = ((pageNumber - 1) * pageSize);
            String query = 'SELECT Id, Name, TitleURL__c, SummaryURL__c, ImageURL__c, ' + 
                            'CreatedDate__c,  Customer_Card__r.Department__c FROM RPA__c ';
            if (String.isNotEmpty(deptName)) {
                query += 'WHERE Customer_Card__r.Department__c LIKE :deptName ';
            }
            query += 'ORDER BY CreatedDate__c DESC, Name DESC LIMIT :pageSize OFFSET :offset';
            System.debug('query: ' + query);
            List<RPA__c> listRpa = Database.query(String.escapeSingleQuotes(query));
            return listRpa;
        }
         catch (Exception e) {
            System.debug(e.getStackTraceString());
            throw new DmlException('err: ' + e.getMessage());
        }
    }

    /**
     * get information of all keyword-related records
     * @param keyword department value
     * @return Integer number of news
     */
    @AuraEnabled
    public static List<RPA__c> getRpasByKeyword(String keyword){
        try {
            keyword = '%' + keyword + '%';
            String query = 'SELECT TitleURL__c, SummaryURL__c, URL__c, ' + 
                            'Customer_Card__r.Industry FROM RPA__c ' +
                            'WHERE TitleURL__c LIKE :keyword ' +
                            'OR URL__c LIKE :keyword ' +
                            'OR SummaryURL__c LIKE :keyword ' +
                            'OR Customer_Card__r.Industry LIKE :keyword ' +
                            'ORDER BY CreatedDate__c DESC, Name DESC';
            List<RPA__c> searchResults = Database.query(String.escapeSingleQuotes(query));
            System.debug('search result: ' + searchResults);
            return searchResults;
        }
        catch (Exception e) {
            System.debug(e.getStackTraceString());
            throw new DmlException('err: ' + e.getMessage());
        }
    }
}
