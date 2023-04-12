/**
 * Author       : Kevin Antonioli (braveitnow@pm.me)
 * Description  : Utility class for plucking values from queried SObject records
 * Created      : 04.05.2023
 *
 * Revisions:
 */
public without sharing class PluckUtils {
  /**
   * @description: Given a list and an SObjectField, return a set of the extracted ids
   *  (Example: Given a list of contacts where prop=Contact.AccountId, return a set of the account ids)
   * @param   records a list of SObject records to extract ids from
   * @param   prop    id field (ex: AccountId) to derive the id values from
   * @return  ids     set of extracted ids
   */
  public static Set<Id> pluckIdSet(
    List<SObject> records,
    Schema.SObjectField prop
  ) {
    Set<Id> ids = new Set<Id>();
    for (SObject obj : records) {
      try {
        if (obj.get(prop) != null) {
          ids.add((Id) obj.get(prop));
        }
      } catch (Exception ex) {
        System.debug(
          'Error processing record, ignoring ' + ex.getStackTraceString()
        );
      }
    }
    return ids;
  }

  /**
   * @description: Given a query string, ids to bind query to, and an SObjectField, return a set of the extracted ids
   *  This flavor of the method takes a query string and a set of ids to bind to to inject into a SOQL for loop
   *  to reduce heap size.
   * @param   queryStr      query to perform to get the SObject records to pluck ids from
   * @param   queryBindIds  ids to bind query to
   * @param   prop          id field (ex: AccountId) to derive the id values from
   * @return  ids           set of extracted ids
   */
  public static Set<Id> pluckIdSet(
    String queryStr,
    Set<Id> queryBindIds,
    Schema.SObjectField prop
  ) {
    Set<Id> ids = new Set<Id>();
    for (SObject obj : Database.query(queryStr)) {
      try {
        if (obj.get(prop) != null) {
          ids.add((Id) obj.get(prop));
        }
      } catch (Exception ex) {
        System.debug(
          'Error processing record, ignoring ' + ex.getStackTraceString()
        );
      }
    }
    return ids;
  }

  /**
   * Given a list and a string property (of an ID field), return a set of the extracted ids
   * (Example: Given a list of contacts where prop='AccountId', return a set of the account Id's)
   * This method allows relationships - Ex. 'Account.CreatedBy.Id'
   * @param  records  a list of SObject records to extract ids from
   * @param  prop     id field (ex: AccountId) to derive the id values from
   * @return ids      set of extracted ids
   */
  public static Set<Id> pluckIdSet(List<SObject> records, String prop) {
    Set<Id> ids = new Set<Id>();
    for (SObject obj : records) {
      try {
        if (prop.contains('.')) {
          SObject currObj = obj;
          for (String field : prop.split('\\.')) {
            try {
              currObj = (SObject) currObj.getSobject(field);
            } catch (Exception ex) {
              ids.add((Id) currObj.get(field));
            }
          }
        } else if (obj.get(prop) != null) {
          ids.add((Id) obj.get(prop));
        }
      } catch (Exception ex) {
        System.debug(
          'Error processing record, ignoring ' + ex.getStackTraceString()
        );
      }
    }
    return ids;
  }

  /**
   * @description: Given a query string, ids to bind query to, and a field/field path, return a set of the extracted ids
   *  This flavor of the method takes a query string and a set of ids to bind to to inject into a SOQL for loop
   *  to reduce heap size.
   * @param   queryStr      query to perform to get the SObject records to pluck ids from
   * @param   queryBindIds  ids to bind query to
   * @param   prop          String field (ex: 'AccountId') or field path (ex: 'Account.Owner.Name') to derive the id values from
   * @return  ids           set of extracted ids
   */
  public static Set<Id> pluckIdSet(
    String queryStr,
    Set<Id> queryBindIds,
    String prop
  ) {
    Set<Id> ids = new Set<Id>();
    for (SObject obj : Database.query(queryStr)) {
      try {
        if (prop.contains('.')) {
          SObject currObj = obj;
          for (String field : prop.split('\\.')) {
            try {
              currObj = (SObject) currObj.getSobject(field);
            } catch (Exception ex) {
              ids.add((Id) currObj.get(field));
            }
          }
        } else if (obj.get(prop) != null) {
          ids.add((Id) obj.get(prop));
        }
      } catch (Exception ex) {
        System.debug(
          'Error processing record, ignoring ' + ex.getStackTraceString()
        );
      }
    }
    return ids;
  }

  /**
   * Given a list and a string property (of a String field), return a set of the extracted values
   * (Example: Given a list of contacts where prop=Contact.FirstName, return a set of the contacts first name)
   * @param  records  a list of SObject records to extract values from
   * @param  prop     field (ex: Contact.FirstName) to derive the values from
   * @return ids      set of extracted ids
   */
  public static Set<String> pluckStringSet(
    List<SObject> records,
    Schema.SObjectField prop
  ) {
    Set<String> strings = new Set<String>();
    for (SObject obj : records) {
      try {
        if (obj.get(prop) != null) {
          strings.add((String) obj.get(prop));
        }
      } catch (Exception ex) {
        System.debug(
          'Error processing record, ignoring ' + ex.getStackTraceString()
        );
      }
    }
    return strings;
  }

  /**
   * @description: Given a query string, ids to bind query to, and an SObjectField, return a set of the extracted values
   *  This flavor of the method takes a query string and a set of ids to bind to to inject into a SOQL for loop
   *  to reduce heap size.
   * @param   queryStr      query to perform to get the SObject records to pluck string values from
   * @param   queryBindIds  ids to bind query to
   * @param   prop          id field (ex: AccountId) to derive the id values from
   * @return  ids           set of extracted ids
   */
  public static Set<String> pluckStringSet(
    String queryStr,
    Set<Id> queryBindIds,
    Schema.SObjectField prop
  ) {
    Set<String> strings = new Set<String>();
    for (SObject obj : Database.query(queryStr)) {
      try {
        if (obj.get(prop) != null) {
          strings.add((String) obj.get(prop));
        }
      } catch (Exception ex) {
        System.debug(
          'Error processing record, ignoring ' + ex.getStackTraceString()
        );
      }
    }
    return strings;
  }

  /**
   * Given a list and a string property (of a String field), return a set of the extracted values
   * The string version provides the ability to get relationship fields - e.x. 'Account.CreatedBy.Name'
   * @param   records   a list of SObject records to extract values from
   * @param   prop      string field path (ex: 'Contact.AccountId') to derive the values from
   * @return  strings   extracted strings
   */
  public static Set<String> pluckStringSet(List<SObject> records, String prop) {
    Set<String> strings = new Set<String>();
    for (SObject obj : records) {
      try {
        if (prop.contains('.')) {
          SObject currObj = obj;
          for (String field : prop.split('\\.')) {
            try {
              currObj = (SObject) currObj.getSobject(field);
            } catch (Exception ex) {
              strings.add((String) currObj.get(field));
            }
          }
        } else if (obj.get(prop) != null) {
          strings.add((String) obj.get(prop));
        }
      } catch (Exception ex) {
        System.debug(
          'Error processing record, ignoring ' + ex.getStackTraceString()
        );
      }
    }
    return strings;
  }

  /**
   * @description: Given a query string, ids to bind query to, and a field/field path, return a set of the extracted ids
   *  This flavor of the method takes a query string and a set of ids to bind to to inject into a SOQL for loop
   *  to reduce heap size.
   * @param   queryStr      query to perform to get the SObject records to pluck ids from
   * @param   queryBindIds  ids to bind query to
   * @param   prop          String field (ex: 'AccountId') or field path (ex: 'Account.Owner.Name') to derive the id values from
   * @return  ids           set of extracted ids
   */
  public static Set<String> pluckStringSet(
    String queryStr,
    Set<Id> queryBindIds,
    String prop
  ) {
    Set<String> strings = new Set<String>();
    for (SObject obj : Database.query(queryStr)) {
      try {
        if (prop.contains('.')) {
          SObject currObj = obj;
          for (String field : prop.split('\\.')) {
            try {
              currObj = (SObject) currObj.getSobject(field);
            } catch (Exception ex) {
              strings.add((String) currObj.get(field));
            }
          }
        } else if (obj.get(prop) != null) {
          strings.add((String) obj.get(prop));
        }
      } catch (Exception ex) {
        System.debug(
          'Error processing record, ignoring ' + ex.getStackTraceString()
        );
      }
    }
    return strings;
  }
}