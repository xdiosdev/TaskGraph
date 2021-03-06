//
//  ListsViewController.m
//  GraphTasks
//
//  Created by Тимур Юсипов on 03.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListsViewController.h"
#import "ProjectsViewController.h"
#import "FocusedAndContextedViewController.h"
#import "_43FoldersTableViewController.h"


#import "BadgedCell.h"

#define TITLE_REGULAR @"Меню"
#define TITLE_CONTEXTED @"Существующие котексты"

#define KEY_DONE @ "done"
#define KEY_UNDONE @"undone"

/*
//
// Данный контроллер предлагает пользователю выбор типа списка проектов или заданий.
// "Все", "Ближайшие" и различные контекстные списки
//
*/


@implementation ListsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _numbersForCellsDataSource = [NSMutableDictionary new];
        [_numbersForCellsDataSource setObject:[NSMutableArray new] forKey:TITLE_CONTEXTED];
        [self reloadData];
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"Группы";
    [self reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(void)setBarButtonItemTitleALLorUNDONE
{
    _shouldSetBarButtonItemTitleALLorUNDONE = !_shouldSetBarButtonItemTitleALLorUNDONE;
}

-(void) reloadData
{
    NSArray* regularTasks = [NSArray arrayWithObjects:@"Все", @"Ближайшие", @"43 папки GTD", nil];
     
    NSManagedObjectContext* context = [[NMTaskGraphManager sharedManager] managedContext];
    NSFetchRequest* request = [NSFetchRequest new];
    NSEntityDescription* entity;
    NSArray* resultsOfFetchExec;
    
    [[_numbersForCellsDataSource objectForKey:TITLE_CONTEXTED] removeAllObjects];
    
    //подсчет общего числа заданий и числа сделанных из них
    entity = [NSEntityDescription entityForName:@"NMTGTask" inManagedObjectContext:context];
    [request setEntity:entity];
    resultsOfFetchExec = [context executeFetchRequest:request error:nil];
    
    NSUInteger done = 0;
    for (NMTGTask* task in resultsOfFetchExec) {
        if ([task.done isEqualToNumber:[NSNumber numberWithBool:YES]]) {done++;}
    }
    [_numbersForCellsDataSource setObject: [NSArray arrayWithObjects: [NSString stringWithFormat:@"%i",done], [NSString stringWithFormat:@"%i", resultsOfFetchExec.count - done], nil] forKey:TITLE_REGULAR];

    
    //поиск всех контекстов
    entity = [NSEntityDescription entityForName:@"NMTGContext" inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSSortDescriptor* sortdescriptor = [[NSSortDescriptor alloc] initWithKey:@"isDefaultContext" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortdescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    
    [controller performFetch:nil];
    _allContexts = controller.fetchedObjects;
    [request setSortDescriptors:nil];
    
    
    _tableDataSource = [NSDictionary dictionaryWithObjectsAndKeys:regularTasks,TITLE_REGULAR, _allContexts, TITLE_CONTEXTED , nil];
    
    
    //подсчет общего числа заданий с заданным контекстом и числа сделанных из них
    int index = 0;
    for (NMTGContext* nmtgcontext in _allContexts) {
        entity = [NSEntityDescription entityForName:@"NMTGTask" inManagedObjectContext:context];
        [request setEntity:entity];
        
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"context == %@", (nmtgcontext.name)];
        [request setPredicate:predicate];
        
        resultsOfFetchExec = [context executeFetchRequest:request error:nil];
        NSUInteger done = 0;
        NSUInteger undone = 0;
        for (NMTGAbstract* obj in resultsOfFetchExec) {
            if ([obj.done isEqualToNumber:[NSNumber numberWithBool:YES]]) {done++;}
            else {undone++;}
        }
        [[_numbersForCellsDataSource objectForKey:TITLE_CONTEXTED] addObject: [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%i", done], KEY_DONE, [NSString stringWithFormat:@"%i",undone], KEY_UNDONE, nil]];
         index++;
    }
    
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[_tableDataSource allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray* allKeys = [_tableDataSource allKeys];
    NSString* particularKey = [allKeys objectAtIndex:section];
    return [[_tableDataSource objectForKey:particularKey] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";   
    BadgedCell *cell = [[BadgedCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    
    NSArray* allKeys = [_tableDataSource allKeys];
    NSString* particularKey = [allKeys objectAtIndex:indexPath.section];
    NSArray* objectsForParticularKey = [_tableDataSource objectForKey:particularKey];
    
    switch (indexPath.section) {
        case 0: //иконки и лэйблы для ВСЕ и БЛИЖАЙШИЕ
        {
            cell.textLabel.text = [objectsForParticularKey objectAtIndex:indexPath.row];
            
            cell.badgeString3 = [[_numbersForCellsDataSource objectForKey:TITLE_REGULAR] objectAtIndex:0];
            cell.badgeString1 = [[_numbersForCellsDataSource objectForKey:TITLE_REGULAR] objectAtIndex:1];
            
//            cell.badgeColor1 = [UIColor colorWithRed:0.712 green:0.712 blue:0.712 alpha:1.000];
//            cell.badgeColor3 = [UIColor colorWithRed:0.192 green:0.812 blue:0.100 alpha:1.000];

            cell.badgeColor1 = [UIColor colorWithRed:0.812 green:0.192 blue:0.100 alpha:1.000];
            cell.badgeColor3 = [UIColor colorWithRed:0.192 green:0.812 blue:0.100 alpha:1.000];

            switch (indexPath.row) {
                case 0:
                    cell.imageView.image = [UIImage imageNamed:@"all_tasks_30x30.png"];
                    break;
                case 1:
                    cell.imageView.image = [UIImage imageNamed:@"focused_30x30.png"];
                    break;
                case 2:
                    cell.imageView.image = [UIImage imageNamed:@"43.png"];
                    break;
                default:
                    break;
            }
            break;
        }
        case 1: //иконки и лэйблы для списков с контекстом
        {
            NSString *celltitle = [[objectsForParticularKey objectAtIndex:indexPath.row] name];
            cell.textLabel.text = ([celltitle isEqualToString:@""]) ? (@"Без контекста") : (celltitle);

            cell.badgeString3 = [[[_numbersForCellsDataSource objectForKey:TITLE_CONTEXTED] objectAtIndex:indexPath.row] objectForKey:KEY_DONE];
            cell.badgeString1 = [[[_numbersForCellsDataSource objectForKey:TITLE_CONTEXTED] objectAtIndex:indexPath.row] objectForKey:KEY_UNDONE];
            
//            cell.badgeColor1 = [UIColor colorWithRed:0.712 green:0.712 blue:0.712 alpha:1.000];
//            cell.badgeColor3 = [UIColor colorWithRed:0.192 green:0.812 blue:0.100 alpha:1.000];
            
            cell.badgeColor1 = [UIColor colorWithRed:0.812 green:0.192 blue:0.100 alpha:1.000];
            cell.badgeColor3 = [UIColor colorWithRed:0.192 green:0.812 blue:0.100 alpha:1.000];

            cell.imageView.image = [UIImage imageNamed:[[objectsForParticularKey objectAtIndex:indexPath.row] iconName]];
            break;
        }
        default:
            break;
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return TITLE_REGULAR;
            break;
        case 1:
            return TITLE_CONTEXTED;
            break;
        default:
            return @"";
            break;
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0: //тут ВСЕ и БЛИЖАЙШИЕ
        {
            switch (indexPath.row) {
                case 0: //ВСЕ
                {
//                    ProjectsViewController* pvc = [[ProjectsViewController alloc]init];
//                    [pvc setTabBarItem:[[UITabBarItem alloc]initWithTitle:@"Projects" image:nil tag:0]];
                    TaskViewController* vc = [[TaskViewController alloc] initWithStyle:UITableViewStylePlain];
                    [self.navigationController pushViewController:vc animated:YES];
                    break;
                }
                case 1: //БЛИЖАЙШИЕ
                {
                    FocusedAndContextedViewController* vc = [[FocusedAndContextedViewController alloc]initWithStyle:UITableViewStylePlain];
                    [self.navigationController pushViewController:vc animated:YES];
                    break;
                }
                case 2: //43 папки GTD
                {
//                    TaskViewController* vc = [[TaskViewController alloc] initWithStyle:UITableViewStylePlain];
//                    [self.navigationController pushViewController:vc animated:YES];
                    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 1: //тут список контекстов
        {
            NSArray* allContexts = [_tableDataSource objectForKey:TITLE_CONTEXTED];
            FocusedAndContextedViewController* focusedVC = [[FocusedAndContextedViewController alloc]initWithStyle:UITableViewStylePlain];
            focusedVC.contextToFilterTasks = [[allContexts objectAtIndex:indexPath.row] name];
            focusedVC.shouldShowOnlyUnDone = _shouldSetBarButtonItemTitleALLorUNDONE;
            [self.navigationController pushViewController:/*taskContextVC*/focusedVC animated:YES];
            break;
        }
            
        default:
            break;
    }

}


@end
