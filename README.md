# Pluck_Utils

Easily extract values from a list of SObject records by a specified field or field path

Usage:

Extract the Account.CreatedBy.Id values from a list of Contacts:
```java
// sample data:
List<Contact> contacts = [SELECT Id, Account.CreatedBy.Id FROM Contact LIMIT 10];

// pluck Account.CreatedBy.Id values from contacts:
Set<Id> createdByIds = PluckUtils.pluckIdSet(contacts, 'Account.CreatedBy.Id'); 
```
-----------------------
Extract the Account.CreatedBy.Name values from a list of Contacts:

```java
// sample data:
List<Contact> contacts = [SELECT Id, Account.CreatedBy.Name FROM Contact LIMIT 10];

// pluck Account.CreatedBy.Name values from contacts:
Set<String> createdByNames = PluckUtils.pluckStringSet(contacts, 'Account.CreatedBy.Name'); 
```
-----------------------
Extract the Account.CreatedBy.Name values from a list of Contacts, while reducing the strain on heap size:

```java
// sample data:
Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id FROM Contact LIMIT 10]);

// pluck Account.CreatedBy.Name values:
Set<String> createdByNames = PluckUtils.pluckStringSet(
    'SELECT Account.CreatedBy.Name FROM Contact WHERE Id IN :queryBindIds',
    contactMap.keyset(),       /* queryBindIds */
    'Account.CreatedBy.Name'   /* fieldPath */
); 
```
