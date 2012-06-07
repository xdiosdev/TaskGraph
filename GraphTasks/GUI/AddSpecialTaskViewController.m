//
//  AddSpecialTaskViewController.m
//  GraphTasks
//
//  Created by Тимур Юсипов on 03.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AddSpecialTaskViewController.h"
#import "AddPropertiesViewController.h"

@implementation AddSpecialTaskViewController

@synthesize parentProject = _parentProject ,
            taskSMS = _taskSMS, 
            taskEmail = _taskEmail,
            taskPhone = _taskPhone;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _tableDataSource = [[NSMutableArray alloc]initWithObjects:@"Выбрать из списка контактов", @"Создать новый контакт",nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.taskSMS) self.navigationItem.title = @"Отправить SMS";
    if (self.taskPhone) self.navigationItem.title = @"Позвонить";
    if (self.taskEmail) self.navigationItem.title = @"Отправить e-Mail";    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _tableDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.textLabel.text = [_tableDataSource objectAtIndex:indexPath.row];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            [self showPeoplePickerController];
            break;
        case 1:
            [self showNewPersonViewController];
            break;
            case 2:
        default:
            break;
    }
}


-(void)showPeoplePickerController
{
	ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;

    NSMutableArray *displayedItems = [NSMutableArray new];
    if (self.taskPhone || self.taskSMS) {
        [displayedItems addObject:[NSNumber numberWithInt:kABPersonPhoneProperty]];
    } else {
        [displayedItems addObject:[NSNumber numberWithInt:kABPersonEmailProperty]];
    }
    
	picker.displayedProperties = displayedItems;
	[self presentModalViewController:picker animated:YES];
}

-(void)showNewPersonViewController
{
	ABNewPersonViewController *picker = [[ABNewPersonViewController alloc] init];
	picker.newPersonViewDelegate = self;
	
	UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:picker];
	[self presentModalViewController:navigation animated:YES];
}

-(void)showPersonViewController
{
	// Fetch the address book 
	ABAddressBookRef addressBook = ABAddressBookCreate();

    ABRecordRef person = (ABRecordRef)[people objectAtIndex:0];
    ABPersonViewController *picker = [[ABPersonViewController alloc] init];
    picker.personViewDelegate = self;
    picker.displayedPerson = person;
    // Allow users to edit the person’s information
    picker.allowsEditing = YES;
    [self.navigationController pushViewController:picker animated:YES];
	CFRelease(addressBook);
}








#pragma mark ABPeoplePickerNavigationControllerDelegate methods
// Displays the information of a selected person
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{

	return YES;
}


// Does not allow users to perform default actions such as dialing a phone number, when they select a person property.
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    
    NSString *firstName = (__bridge NSString *)ABRecordCopyValue(person, 
                                                                 kABPersonFirstNameProperty);
    NSString *lastName = (__bridge NSString *)ABRecordCopyValue(person, 
                                                                kABPersonLastNameProperty);
    
    //формирование словаря доп информации
    NSString *key;
    NSString *value;
    
    
    if (self.taskSMS) key = @"Отправить SMS";
    else if (self.taskPhone) key = @"Позвонить";
    else if (self.taskEmail) key = @"e-Mail";
    
    if (self.taskSMS || self.taskPhone) {
        ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
        NSArray *phonenumbers = (__bridge NSArray* )ABMultiValueCopyArrayOfAllValues(phones);
        value = [NSString stringWithFormat:@"%@",[phonenumbers objectAtIndex:identifier]];
    } else {
        ABMultiValueRef mails = ABRecordCopyValue(person, kABPersonEmailProperty);
        NSArray *emails = (__bridge NSArray* )ABMultiValueCopyArrayOfAllValues(mails);
        value = [NSString stringWithFormat:@"%@",[emails objectAtIndex:identifier]];
    }
    
    
    AddPropertiesViewController* addPropertiesVC = [[AddPropertiesViewController alloc] initWithStyle:UITableViewStyleGrouped];

    [addPropertiesVC setTasksName:[NSString stringWithFormat:@"%@ %@", firstName, lastName]];
    [addPropertiesVC setTasksKeyDescribingType:key AndItsValue:value];
    
    [addPropertiesVC setParentProject: self.parentProject];
    [addPropertiesVC setTaskSMS: self.taskSMS];
    [addPropertiesVC setTaskMail: self.taskEmail];
    [addPropertiesVC setTaskPhone:self.taskPhone];

    [self dismissModalViewControllerAnimated:NO];
    [self.navigationController pushViewController:addPropertiesVC animated:YES];
	return NO;
}


// Dismisses the people picker and shows the application when users tap Cancel. 
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker;
{
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark ABPersonViewControllerDelegate methods
// Does not allow users to perform default actions such as dialing a phone number, when they select a contact property.
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person 
					property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue
{

	return NO;
}


#pragma mark ABNewPersonViewControllerDelegate methods
// Dismisses the new-person view controller. 
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person
{
	[self dismissModalViewControllerAnimated:YES];
}




@end
