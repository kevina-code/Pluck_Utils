/**
 * Author       : Kevin Antonioli (braveitnow@pm.me)
 * Description  : provides apex code coverage for PluckUtils.cls
 * Created      : 04.05.2023
 *
 * Revisions:
 * Date : Name : Notes
 */
@isTest
public with sharing class PluckUtilsTest {
  @isTest
  static void test_pluckIdSet() {
    List<Account> accounts = createTestAccounts();
    Set<Id> accountIds = PluckUtils.pluckIdSet(accounts, Schema.Account.Id);
    Assert.areEqual(
      3,
      accountIds.size(),
      'Expected accountIds set size to be 3'
    );
  }

  @isTest
  static void test_pluckIdSetNonMatching() {
    List<Account> accounts = createTestAccounts();
    Set<Id> accountIds = PluckUtils.pluckIdSet(accounts, Schema.Contact.Name);
    Assert.areEqual(
      0,
      accountIds.size(),
      'Expected accountIds set size to be 0'
    );
  }

  @isTest
  static void test_pluckIdSet_queryException() {
    List<Account> accounts = createTestAccounts();
    Map<Id, Account> accountMap = new Map<Id, Account>(accounts);

    Set<Id> accountIds = new Set<Id>();
    try {
      accountIds = PluckUtils.pluckIdSet(
        'SELECT Iddd FROM Account WHERE Id IN :queryBindIds',
        accountMap.keySet() /* queryBindIds */,
        Schema.Contact.Name /* prop */
      );
      Assert.fail('Invalid query field exception Expected');
    } catch (Exception e) {
      Assert.isTrue(e.getMessage().contains('No such column'));
    }

    Assert.areEqual(
      0,
      accountIds.size(),
      'Expected accountIds set size to be 0'
    );
  }

  @isTest
  static void test_pluckIdSetRelationship() {
    List<Contact> contacts = new List<Contact>{
      new Contact(
        LastName = '1',
        Account = new Account(
          Name = 'Account 1',
          Parent = new Account(
            Id = getFakeId(Account.getSObjectType()),
            Name = 'parent-account-1'
          )
        )
      ),
      new Contact(
        LastName = '2',
        Account = new Account(
          Name = 'Account 2',
          Parent = new Account(
            Id = getFakeId(Account.getSObjectType()),
            Name = 'parent-account-2'
          )
        )
      ),
      new Contact(
        LastName = '3',
        Account = new Account(
          Name = 'Account 3',
          Parent = new Account(
            Id = getFakeId(Account.getSObjectType()),
            Name = 'parent-account-3'
          )
        )
      ),
      new Contact(
        LastName = '4',
        Account = new Account(
          Name = 'Account 4',
          Parent = new Account(
            Id = getFakeId(Account.getSObjectType()),
            Name = 'parent-account-4'
          )
        )
      ),
      new Contact(LastName = '5', Account = new Account(Name = 'Account 4')),
      new Contact(LastName = '5')
    };
    Set<Id> userIds = PluckUtils.pluckIdSet(contacts, 'Account.Parent.Id');
    Assert.areEqual(4, userIds.size(), 'Expected userIds set size to be 4');
  }

  @isTest
  static void test_pluckIdSet_queryStrParam() {
    List<Account> accounts = createTestAccounts();
    Map<Id, Account> accountMap = new Map<Id, Account>(accounts); // in a real scenario, this might be trigger.newMap

    Test.startTest();
    Set<Id> pluckedAccountIds = PluckUtils.pluckIdSet(
      'SELECT Id FROM Account WHERE Id IN :queryBindIds',
      accountMap.keySet() /* queryBindIds */,
      Schema.Account.Id /* prop */
    );
    Test.stopTest();

    Assert.isTrue(
      pluckedAccountIds.contains(accounts[0].Id),
      'Expected the pluckedAccountIds to contain the first account id'
    );
    Assert.isTrue(
      pluckedAccountIds.contains(accounts[1].Id),
      'Expected the pluckedAccountIds to contain the second account id'
    );
    Assert.isTrue(
      pluckedAccountIds.contains(accounts[2].Id),
      'Expected the pluckedAccountIds to contain the third account id'
    );
  }

  @isTest
  static void test_pluckIdSet_queryStrParam2() {
    List<Account> accounts = createTestAccounts();
    accounts[0].Type = 'Franchise';
    accounts[1].Type = 'Franchise';
    accounts[2].Type = 'Client';
    update accounts;

    List<Contact> contacts = new List<Contact>();
    contacts.add(
      new Contact(
        FirstName = 'Ron',
        LastName = 'Burgandy',
        AccountId = accounts[0].Id
      )
    );
    contacts.add(
      new Contact(
        FirstName = 'Jack',
        LastName = 'Black',
        AccountId = accounts[1].Id
      )
    );
    contacts.add(
      new Contact(
        FirstName = 'Rose',
        LastName = 'Parks',
        AccountId = accounts[2].Id
      )
    );
    insert contacts;
    Map<Id, Contact> contactMap = new Map<Id, Contact>(contacts); // in a real scenario, this might be trigger.newMap

    Test.startTest();
    Set<Id> pluckedAccountIds = PluckUtils.pluckIdSet(
      'SELECT Id, AccountId FROM Contact WHERE Id IN :queryBindIds',
      contactMap.keySet() /* queryBindIds */,
      'AccountId' /* prop */
    );
    Test.stopTest();

    Assert.isTrue(
      pluckedAccountIds.contains(accounts[0].Id),
      'Expected pluckedAccountIds to contain the first account id"'
    );
    Assert.isTrue(
      pluckedAccountIds.contains(accounts[1].Id),
      'Expected pluckedAccountIds to contain the second account id'
    );
    Assert.isTrue(
      pluckedAccountIds.contains(accounts[2].Id),
      'Expected pluckedAccountIds to contain the third account id'
    );
  }

  @isTest
  static void test_pluckIdSet_queryStrParam3() {
    List<Account> accounts = createTestAccounts();
    accounts[0].OwnerId = UserInfo.getUserId();
    accounts[1].OwnerId = UserInfo.getUserId();
    accounts[2].OwnerId = UserInfo.getUserId();
    update accounts;

    List<Contact> contacts = new List<Contact>();
    contacts.add(
      new Contact(
        FirstName = 'Ron',
        LastName = 'Burgandy',
        AccountId = accounts[0].Id
      )
    );
    contacts.add(
      new Contact(
        FirstName = 'Jack',
        LastName = 'Black',
        AccountId = accounts[1].Id
      )
    );
    contacts.add(
      new Contact(
        FirstName = 'Rose',
        LastName = 'Parks',
        AccountId = accounts[2].Id
      )
    );
    insert contacts;
    Map<Id, Contact> contactMap = new Map<Id, Contact>(contacts); // in a real scenario, this might be trigger.newMap

    Test.startTest();
    Set<Id> pluckedProfileIds = PluckUtils.pluckIdSet(
      'SELECT Id, Account.Owner.ProfileId FROM Contact WHERE Id IN :queryBindIds',
      contactMap.keySet() /* queryBindIds */,
      'Account.Owner.ProfileId' /* prop */
    );
    Test.stopTest();

    accounts = [SELECT Id, Owner.ProfileId FROM Account WHERE Id IN :accounts];

    Assert.isTrue(
      pluckedProfileIds.contains(accounts[0].Owner.ProfileId),
      'Expected pluckedProfileIds to contain the Account owner profile id"'
    );
    Assert.isTrue(
      pluckedProfileIds.contains(accounts[1].Owner.ProfileId),
      'Expected pluckedProfileIds to contain the Account owner profile id"'
    );
    Assert.isTrue(
      pluckedProfileIds.contains(accounts[2].Owner.ProfileId),
      'Expected pluckedProfileIds to contain the Account owner profile id"'
    );
  }

  @isTest
  static void test_pluckStringSet_queryStrParam() {
    List<Account> accounts = createTestAccounts();
    Map<Id, Account> accountMap = new Map<Id, Account>(accounts); // in a real scenario, this might be trigger.newMap
    accounts[0].Type = 'Franchise';
    accounts[1].Type = 'Franchise';
    accounts[2].Type = 'Client';
    update accounts;

    Test.startTest();
    Set<String> pluckedAccountTypes = PluckUtils.pluckStringSet(
      'SELECT Id, Type FROM Account WHERE Id IN :queryBindIds',
      accountMap.keySet() /* queryBindIds */,
      Schema.Account.Type /* prop */
    );
    Test.stopTest();

    Assert.isTrue(
      pluckedAccountTypes.contains(accounts[0].Type),
      'Expected the pluckedAccountTypes list to contain "Franchise"'
    );
    Assert.isTrue(
      pluckedAccountTypes.contains(accounts[1].Type),
      'Expected the pluckedAccountTypes list to contain "Franchise"'
    );
    Assert.isTrue(
      pluckedAccountTypes.contains(accounts[2].Type),
      'Expected the pluckedAccountTypes list to contain "Client"'
    );
  }

  @isTest
  static void test_pluckStringSet_queryStrParam2() {
    List<Account> accounts = createTestAccounts();
    accounts[0].Type = 'Franchise';
    accounts[1].Type = 'Franchise';
    accounts[2].Type = 'Client';
    update accounts;

    List<Contact> contacts = new List<Contact>();
    contacts.add(
      new Contact(
        FirstName = 'Ron',
        LastName = 'Burgandy',
        AccountId = accounts[0].Id
      )
    );
    contacts.add(
      new Contact(
        FirstName = 'Jack',
        LastName = 'Black',
        AccountId = accounts[1].Id
      )
    );
    contacts.add(
      new Contact(
        FirstName = 'Rose',
        LastName = 'Parks',
        AccountId = accounts[2].Id
      )
    );
    insert contacts;
    Map<Id, Contact> contactMap = new Map<Id, Contact>(contacts); // in a real scenario, this might be trigger.newMap

    Test.startTest();
    Set<String> pluckedAccountTypes = PluckUtils.pluckStringSet(
      'SELECT Id, Account.Type FROM Contact WHERE Id IN :queryBindIds',
      contactMap.keySet() /* queryBindIds */,
      'Account.Type' /* prop */
    );

    Set<String> pluckedFirstNames = PluckUtils.pluckStringSet(
      'SELECT Id, FirstName FROM Contact WHERE Id IN :queryBindIds',
      contactMap.keySet() /* queryBindIds */,
      'FirstName' /* prop */
    );
    Test.stopTest();

    Assert.isTrue(
      pluckedAccountTypes.contains('Franchise'),
      'Expected pluckedAccountTypes to contain "Franchise"'
    );
    Assert.isTrue(
      pluckedAccountTypes.contains('Client'),
      'Expected pluckedAccountTypes to contain "Client"'
    );

    Assert.isTrue(
      pluckedFirstNames.contains('Ron'),
      'Expected pluckedFirstNames to contain "Ron"'
    );
    Assert.isTrue(
      pluckedFirstNames.contains('Jack'),
      'Expected pluckedFirstNames to contain "Jack"'
    );
    Assert.isTrue(
      pluckedFirstNames.contains('Rose'),
      'Expected pluckedAccountTypes to contain "Rose"'
    );
  }

  @isTest
  static void test_pluckStringSet_SObjectField() {
    List<Account> accounts = createTestAccounts();

    Test.startTest();
    Set<String> accountIds = PluckUtils.pluckStringSet(
      accounts,
      Schema.Account.Name
    );
    Assert.areEqual(3, accountIds.size());
    Test.stopTest();

    Assert.isTrue(accountIds.contains('1'));
    Assert.isTrue(accountIds.contains('2'));
    Assert.isTrue(accountIds.contains('3'));
  }

  @isTest
  static void test_pluckStringSet_StringPath() {
    List<Contact> contacts = new List<Contact>{
      new Contact(
        LastName = '1',
        Account = new Account(
          Name = 'Account 1',
          Parent = new Account(
            Id = getFakeId(Account.getSObjectType()),
            Name = 'parent-account-1'
          )
        )
      ),
      new Contact(
        LastName = '2',
        Account = new Account(
          Name = 'Account 2',
          Parent = new Account(
            Id = getFakeId(Account.getSObjectType()),
            Name = 'parent-account-2'
          )
        )
      ),
      new Contact(
        LastName = '3',
        Account = new Account(
          Name = 'Account 3',
          Parent = new Account(
            Id = getFakeId(Account.getSObjectType()),
            Name = 'parent-account-3'
          )
        )
      ),
      new Contact(
        LastName = '4',
        Account = new Account(
          Name = 'Account 4',
          Parent = new Account(
            Id = getFakeId(Account.getSObjectType()),
            Name = 'parent-account-4'
          )
        )
      ),
      new Contact(
        LastName = 'Smith',
        Account = new Account(Name = 'Account 4')
      ),
      new Contact(LastName = 'Smith')
    };

    Test.startTest();
    Set<String> userNames = PluckUtils.pluckStringSet(
      contacts,
      'Account.Parent.Name'
    );
    Set<String> lastNames = PluckUtils.pluckStringSet(contacts, 'LastName');
    Test.stopTest();

    Assert.areEqual(4, userNames.size(), 'Expected userNames set size to be 4');
    Assert.isTrue(
      lastNames.contains('Smith'),
      'Expected lastNames set to contain "Smith"'
    );
  }

  /** HELPER METHODS */
  private static List<Account> createTestAccounts() {
    List<Account> accounts = new List<Account>();
    accounts.add(new Account(Name = '1'));
    accounts.add(new Account(Name = '2'));
    accounts.add(new Account(Name = '3'));

    insert accounts;
    return accounts;
  }

  private static Contact createTestContact(Account account) {
    return new Contact(
      FirstName = account.Name,
      LastName = account.name,
      AccountId = account.Id
    );
  }

  private static Integer sObjectIdCounter = 1;
  private static String getFakeId(Schema.SobjectType sot) {
    String result = String.valueOf(sObjectIdCounter++);
    return sot.getDescribe().getKeyPrefix() +
      '0'.repeat(12 - result.length()) +
      result;
  }
}