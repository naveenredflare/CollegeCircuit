//
//  MatchesListTableViewController.m
//  CollegeMatchmaker
//
//  Created by Kumar  on 25/11/14.
//  Copyright (c) 2014 Org. All rights reserved.
//

#import "StarsListTableViewController.h"
#import "StarsListTableCell.h"
#import "SWRevealViewController.h"
#import "DetailViewController.h"
#import "ServiceURL.h"

@interface StarsListTableViewController ()

@end

@implementation StarsListTableViewController
@synthesize imageDownloadingQueue, imageCache;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    revealController = [self revealViewController];
    revealController.delegate = self;
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    
    UIImage *buttonImage = [UIImage imageNamed:@"menuicon.png"];
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [aButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    aButton.frame = CGRectMake(0.0, 0.0, buttonImage.size.width,   buttonImage.size.height);
    aButton.adjustsImageWhenHighlighted = NO;
    UIBarButtonItem *aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aButton];
    [aButton addTarget:revealController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationItem setLeftBarButtonItem:aBarButtonItem];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];

    
    self.imageDownloadingQueue = [[NSOperationQueue alloc] init];
    self.imageDownloadingQueue.maxConcurrentOperationCount = 4; // many servers limit how many concurrent requests they'll accept from a device, so make sure to set this accordingly
    
    self.imageCache = [[NSCache alloc] init];
    
    self.title = @"Stars";
    self.navigationController.navigationBar.hidden = NO;
    defaults = [NSUserDefaults standardUserDefaults];
    rowIdArray=[[NSMutableArray alloc]init];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) starsList {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@api/services/favcollegebyuser/",BASEURL]]];
    
    request.HTTPMethod = @"POST";
    
    NSString *stringData = [NSString stringWithFormat:@"user_id=%@",[defaults stringForKey:@"user_id"]];
    NSData *requestBodyData = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = requestBodyData;
    
    connection1 = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self starsList];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [[starsList objectForKey:@"records"] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    StarsListTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StarsListCell"];
    
    if(!cell){
        [tableView registerNib:[UINib nibWithNibName:@"StarsListTableCell" bundle:nil] forCellReuseIdentifier:@"StarsListCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"StarsListCell"];
    }
    // Configure the cell...
    NSString *ImageURL = [NSString stringWithFormat:@"%@media/images/%@",BASEURL,[[[[[starsList objectForKey:@"records"] objectAtIndex:indexPath.row] objectForKey:@"galleryImages"] objectAtIndex:0] objectForKey:@"image_path"]];
    UIImage *cachedImage = [self.imageCache objectForKey:ImageURL];
    
    CGRect rect = CGRectMake(30, 0 ,
                             320, 215);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([cachedImage CGImage], rect);
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    
    if (cachedImage)
    {
        cell.collegeImage.image = newImage;
    } else {
        [self.imageDownloadingQueue addOperationWithBlock:^{
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:ImageURL]];
            UIImage *image = nil;
            if (imageData)
                image = [UIImage imageWithData:imageData];
            
            if (image)
            {
                CGRect rect = CGRectMake(30, 0 ,
                                         320, 215);
                
                CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
                UIImage *newImage1 = [UIImage imageWithCGImage:imageRef];

                // add the image to your cache
                [self.imageCache setObject:newImage1 forKey:ImageURL];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    UITableViewCell *updateCell = [tableView cellForRowAtIndexPath:indexPath];
                    if (updateCell)
                        cell.collegeImage.image = newImage1;
                }];
            }
        }];
    }
    
    cell.collegeName.text = [[[starsList objectForKey:@"records"] objectAtIndex:indexPath.row] objectForKey:@"college_name"];
    
    //cell.collegeAddress.text = [[[starsList objectForKey:@"records"] objectAtIndex:indexPath.row] objectForKey:@"college_address"];
    
    cell.collegeAddress.text = [NSString stringWithFormat:@"%@, %@",[[[starsList objectForKey:@"records"] objectAtIndex:indexPath.row] objectForKey:@"college_county"], [[[starsList objectForKey:@"records"] objectAtIndex:indexPath.row] objectForKey:@"college_state"]];
    
    cell.collegeDeadline.text = [[[starsList objectForKey:@"records"] objectAtIndex:indexPath.row] objectForKey:@"college_appl_deadline"];
    
    cell.collegeStar.tag = indexPath.row;
    [cell.collegeStar addTarget:self action:@selector(starTheCollege:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *star_value = [NSString stringWithFormat:@"%@",[[[starsList objectForKey:@"records"] objectAtIndex:indexPath.row] objectForKey:@"userStar"]];
    NSString *rowIdStr = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    if([star_value isEqualToString:@"0"]){
        //[cell.collegeStar setSelected:NO];
        [rowIdArray removeObject:rowIdStr];
    } else {
        [rowIdArray addObject:rowIdStr];
        //[cell.collegeStar setSelected:YES];
    }
    
    UIImage *buttonImage1 = [UIImage imageNamed:@"starIcon.png"];
    [cell.collegeStar setBackgroundImage:buttonImage1 forState:UIControlStateNormal];
    
    NSString *a=[NSString stringWithFormat:@"%ld", (long)indexPath.row];
    NSString *b=[[NSString alloc]init];
    
    for (int i=0;i<[rowIdArray count];i++)
    {
        b=[rowIdArray  objectAtIndex:i];
        
        if ([a isEqualToString:b])
        {
            
            UIImage *buttonImage = [UIImage imageNamed:@"starIconSelected"];
            [cell.collegeStar setBackgroundImage:buttonImage forState:UIControlStateNormal];
        }
        
    }
    
    //
    
    CGSize size1 = [[[[starsList objectForKey:@"records"] objectAtIndex:indexPath.row] objectForKey:@"favCount"] sizeWithAttributes:
                   @{NSFontAttributeName:
                         [UIFont systemFontOfSize:12.0f]}];
    
    CGSize size = [[[[starsList objectForKey:@"records"] objectAtIndex:indexPath.row] objectForKey:@"college_hits"] sizeWithAttributes:
                   @{NSFontAttributeName:
                         [UIFont systemFontOfSize:12.0f]}];
    
    cell.viewsWidthCount.constant = size.width;
    
    cell.starsWidthCount.constant = size1.width;
    
    cell.viewsCount.text = [[[starsList objectForKey:@"records"] objectAtIndex:indexPath.row] objectForKey:@"college_hits"];
    
    cell.starsCount.text = [[[starsList objectForKey:@"records"] objectAtIndex:indexPath.row] objectForKey:@"favCount"];
    
    return cell;
}

-(void)starTheCollege:(UIButton*)sender
{
    NSString *starred_id=nil;
    starred = NO;
    starred_selectedIndex = [sender tag];
    
    starred_id = [[[starsList objectForKey:@"records"] objectAtIndex:[sender tag]] objectForKey:@"college_id"];
    NSString *star_value = [NSString stringWithFormat:@"%@",[[[starsList objectForKey:@"records"] objectAtIndex:[sender tag]] objectForKey:@"userStar"]];
    starred = ([star_value isEqualToString:@"0"])?NO:YES;
     NSString *rowIdStr = [NSString stringWithFormat:@"%ld", (long)sender.tag];
    if(![rowIdArray containsObject:rowIdStr])
    {
        
        [rowIdArray addObject:rowIdStr];
        
    }else{
        
        [rowIdArray removeObject: rowIdStr];
        
    }
    [self.tableView reloadData];
    if (starred==NO){
    
        //[sender setSelected:YES];
        [self starCollege:starred_id];
    }
    else{
        //[sender setSelected:NO];
            [self unStarCollege:starred_id];
        
    }
    
    
}

-(void)starCollege:(NSString*)starred_id
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@api/services/favcollege/",BASEURL]]];
    
    request.HTTPMethod = @"POST";
    
    NSString *stringData = [NSString stringWithFormat:@"user_id=%@&college_id=%@",[defaults stringForKey:@"user_id"],starred_id];
    NSData *requestBodyData = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = requestBodyData;
    
    connection2 = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

-(void)unStarCollege:(NSString*)starred_id
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@api/services/unfavcollege/",BASEURL]]];
    
    request.HTTPMethod = @"POST";
    
    NSString *stringData = [NSString stringWithFormat:@"user_id=%@&college_id=%@",[defaults stringForKey:@"user_id"],starred_id];
    NSData *requestBodyData = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = requestBodyData;
    
    connection3 = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *) indexPath{
    return 215;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    detailViewController.collegeId = [[[starsList objectForKey:@"records"] objectAtIndex:indexPath.row] objectForKey:@"college_id"];
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    //_responseData = data;
    [_responseData appendData:data];
    
    
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    if(connection == connection1){
        NSData *jsonData = [[[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e;
        NSMutableDictionary *dict = nil;
        dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
        
        
        
        NSLog(@"%@",dict);
        
        if([[dict objectForKey:@"status"] isEqualToString:@"1"]){
            //matchesList = [NSMutableDictionary dictionaryWithDictionary:dict];
            starsList = dict;
            [self.tableView reloadData];
        } else {
            [[[UIAlertView alloc] initWithTitle:nil message:[dict objectForKey:@"message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
        }
    }
    else if(connection == connection2){
        NSData *jsonData = [[[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
        
        NSLog(@"%@",dict);
        if([[dict objectForKey:@"status"] isEqualToString:@"1"]){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self starsList];
            [self.tableView reloadData];
            //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:starred_selectedIndex inSection:1];
        
            //MatchesListTableCell *cell = (MatchesListTableCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
        
            //[cell.collegeStar setSelected:YES];
            //[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            //[self.tableView reloadData];
        } else {
            [[[UIAlertView alloc] initWithTitle:nil message:[dict objectForKey:@"message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
        }
    }
    else if(connection == connection3){
        NSData *jsonData = [[[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
        
        NSLog(@"%@",dict);
        
        if([[dict objectForKey:@"status"] isEqualToString:@"1"]){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self starsList];
            [self.tableView reloadData];
            //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:starred_selectedIndex inSection:1];
            
           //MatchesListTableCell *cell = (MatchesListTableCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
            
            //[cell.collegeStar setSelected:NO];
            //[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            //[self.tableView reloadData];
        } else {
            [[[UIAlertView alloc] initWithTitle:nil message:[dict objectForKey:@"message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
        }
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Ch
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

@end
