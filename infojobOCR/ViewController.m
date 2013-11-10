//
//  ViewController.m
//  infojobOCR
//
//  Created by Paolo Tagliani on 08/06/12.
//  Copyright (c) 2012 26775. All rights reserved.
//
#import "ViewController.h"
#import "ImageProcessingImplementation.h"
#import "UIImage+operation.h"
#import "RegexKitLite.h"


@interface ViewController ()

@end

@implementation ViewController


@synthesize takenImage;
@synthesize process;
@synthesize resultView;
@synthesize imageProcessor;
@synthesize read;
@synthesize processedImage;
@synthesize rotateButton;
@synthesize Histogrambutton;
@synthesize FilterButton;
@synthesize BinarizeButton;
@synthesize originalButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    imageProcessor= [[ImageProcessingImplementation alloc]  init];    
    
	// Do any additional setup after loading the view, typically from a nib.
    
//    NSMutableArray *aryResult =[NSMutableArray arrayWithObject:@"c jhachgdchjvdch 02-04-12"];
//
//    NSString *AMOUNT = [self getAmountString:@"AVINASG HA S TO PARO Amount $300"];
    
    
    
    NSString *txt= @"ï»¿DIRBCdsh ATH"
    "TERMINAL Â«"
    "SEQUENCE *"
    "AUTH It"
    "DATE"
    "CARD NUMBER"
    "CUSTOMER NAME"
    "DISPENSED AMOUNT"
    "REQUESTED AMOUNT"
    "FROM ACCOUNT"
    "TERMINAL FEE"
    "TOTAL AMOUNT"
    "BALANCE"
    "D2016199"
    "19?12"
    "03241 00"
    "02/05/2004 22:54:28"
    "XXXXXXXXXXXX5903"
    "Jimmy Sample"
    "$60.00"
    "$60.00"
    "checking"
    "$1.25"
    "$61.25"
    "= $629,112.23";
    
    NSString *date = [self getDateString:txt];
    NSLog(@"%@",date);
    NSString *AMOUNT = [self getAmountString:txt];
    NSLog(@"%@",AMOUNT);
    NSString *currency = [self getCurrencyString:txt];
    NSLog(@"%@",currency);
    

    
}

- (void)viewDidUnload
{
    [self setResultView:nil];
    [self setProcess:nil];
    [self setRead:nil];
    [self setRotateButton:nil];
    [self setRotateButton:nil];
    [self setHistogrambutton:nil];
    [self setFilterButton:nil];
    [self setBinarizeButton:nil];
    [self setOriginalButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    if(interfaceOrientation == UIInterfaceOrientationPortrait) return YES;
    else return NO;
}

- (IBAction)Pre:(id)sender {
    
    NSLog(@"Dimension taken image: %f x %f",takenImage.size.width, takenImage.size.height);
    self.processedImage=[imageProcessor processImage:[self takenImage]];
    self.resultView.image=[self processedImage];
    NSLog(@"Dimension processed image: %f x %f",takenImage.size.width, takenImage.size.height);

    
}

- (IBAction)OCR:(id)sender {
    
    NSString *result=[imageProcessor OCRImage:[self processedImage]];
    [[[UIAlertView alloc] initWithTitle:@""
                                message:[NSString stringWithFormat:@"Recognized:\n%@", result]
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
    
    result = [result stringByReplacingOccurrencesOfString:@"\n1 " withString:@" "];
    result = [result stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];
    result = [result stringByReplacingOccurrencesOfString:@"\t" withString:@" "];
    result = [result stringByReplacingOccurrencesOfString:@"|" withString:@" "];
    result = [result stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    result = [result stringByReplacingOccurrencesOfString:@"I " withString:@" "];
    
    result = [result stringByReplacingOccurrencesOfString:@" T" withString:@" "];
    NSArray *list = [result componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    [self parseTicket:[NSMutableArray arrayWithArray:list]];
    
    NSString *date = [self getDateString:result];
    NSLog(@"%@",date);
    NSString *AMOUNT = [self getAmountString:result];
    NSLog(@"%@",AMOUNT);
    
    NSString *currency = [self getCurrencyString:result];
    NSLog(@"%@",currency);
}


-(NSString *)getCurrencyString:(NSString *)str
{
    NSMutableArray *emailArray = [NSMutableArray array];
    str =[str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    NSString *EmailregexString = @"[$¥£]";
    NSArray  *EmailmatchArray   = nil;
    EmailmatchArray = [str componentsMatchedByRegex:EmailregexString];
    if([EmailmatchArray count]>0)
    {
        NSString *emailString=[EmailmatchArray objectAtIndex:0];
        [emailArray addObject:emailString];
    }
    return [EmailmatchArray componentsJoinedByString:@","];
}


-(NSString *)getAmountString:(NSString *)str
{
    
    NSString *remainParsingText  =[NSString stringWithString:str];
    
    if([str rangeOfString:@"Amount" options:NSCaseInsensitiveSearch].location!=NSNotFound)
    {
        
        NSString *requiredsAmountID=[str stringByReplacingOccurrencesOfString:@"Amount" withString:@"" options:NSCaseInsensitiveSearch range:[str rangeOfString:@"Amount" options:NSCaseInsensitiveSearch]];
        NSMutableCharacterSet *customSet = [NSMutableCharacterSet characterSetWithCharactersInString:@":@*-().#/,;"];
        requiredsAmountID=[requiredsAmountID stringByTrimmingCharactersInSet:customSet];
        if([requiredsAmountID rangeOfString:@"," options:NSCaseInsensitiveSearch].location!=NSNotFound)
        {
            remainParsingText=[remainParsingText stringByReplacingOccurrencesOfString:str withString:@""];
            requiredsAmountID=[requiredsAmountID stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            return requiredsAmountID;
        }
    }
    
    if([str rangeOfString:@"Total" options:NSCaseInsensitiveSearch].location!=NSNotFound)
    {
        
        NSString *requiredsAmountID=[str stringByReplacingOccurrencesOfString:@"Total" withString:@"" options:NSCaseInsensitiveSearch range:[str rangeOfString:@"Total" options:NSCaseInsensitiveSearch]];
        NSMutableCharacterSet *customSet = [NSMutableCharacterSet characterSetWithCharactersInString:@":@*-().#/,;"];
        requiredsAmountID=[requiredsAmountID stringByTrimmingCharactersInSet:customSet];
        if([requiredsAmountID rangeOfString:@"," options:NSCaseInsensitiveSearch].location!=NSNotFound)
        {
            remainParsingText=[remainParsingText stringByReplacingOccurrencesOfString:str withString:@""];
            requiredsAmountID=[requiredsAmountID stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            return requiredsAmountID;
        }
    }
        
        NSMutableArray *emailArray = [NSMutableArray array];
        str =[str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        NSString *EmailregexString = @"[$].*";
        NSArray  *EmailmatchArray   = nil;
        EmailmatchArray = [str componentsMatchedByRegex:EmailregexString];
        if([EmailmatchArray count]>0)
        {
            NSString *emailString=[EmailmatchArray objectAtIndex:0];
            [emailArray addObject:emailString];
        }
        return [EmailmatchArray componentsJoinedByString:@","];
    }

-(void)parseTicket:(NSMutableArray *)aryResult
{
    
    
//    NSString *country = [self getCounty:aryResult];
//    
//    NSString *citation = [self getCitation:aryResult];
//    
//    NSString *fName = [self getFirstName:aryResult];
//    
//    NSString *lName = [self getLastName:aryResult];
//    
//    
    
    NSString *datetime = [self getDateTime:aryResult];
    
//    NSString *statute = [self getStatute:aryResult];
    
    
//    
//    //        NSLog(@"statute : %@", statute);
//    
//    lblCNo.text = citation;
//    lblStatus.text = statute;
//    lblCountry.text=  country;
//    lblFName.text = fName;
//    lblLName.text = lName;
//    lblDateTime.text = datetime;
    
    
    NSDateFormatter *dtFormat = [[NSDateFormatter alloc] init];
    [dtFormat setDateFormat:@"MMM dd, yyyy hh:mm a"];
    
    NSDate *dt = [dtFormat dateFromString:datetime];
    [dtFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSString *dtDate = [dtFormat stringFromDate:dt];
    if(!dtDate)
        dtDate = @"";
    
//    [self.dicData setObject:citation forKey:@"Citation_Number__c"];
//    [self.dicData setObject:country forKey:@"County__c"];
//    
//    [self.dicData setObject:dtDate forKey:@"Date__c"];
//    [self.dicData setObject:fName forKey:@"First_Name__c"];
//    [self.dicData setObject:lName forKey:@"Last_Name__c"];
//    [self.dicData setObject:statute forKey:@"Statute_Number__c"];
    //    NSLog(@"%@ data parsed", [NSDate date]);
    
    NSLog(@"%@",self.dicData);
    
    
    [[[UIAlertView alloc] initWithTitle:@""
                                message:[NSString stringWithFormat:@"Recognized:\n%@", self.dicData]
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];

    
}



-(NSString *)getDateString:(NSString *)str
{
    
    if([str rangeOfString:@"Date" options:NSCaseInsensitiveSearch].location!=NSNotFound)
    {
        
        NSString *requiredskypeid=[str stringByReplacingOccurrencesOfString:@"Date" withString:@"" options:NSCaseInsensitiveSearch range:[str rangeOfString:@"Date" options:NSCaseInsensitiveSearch]];
        NSMutableCharacterSet *customSet = [NSMutableCharacterSet characterSetWithCharactersInString:@":@*-().#/,;"];
        requiredskypeid=[requiredskypeid stringByTrimmingCharactersInSet:customSet];
        if([requiredskypeid rangeOfString:@"," options:NSCaseInsensitiveSearch].location!=NSNotFound)
        {
            requiredskypeid=[requiredskypeid stringByReplacingOccurrencesOfString:@" " withString:@""];
            return requiredskypeid;
        }
    }
    
    NSMutableArray *emailArray = [NSMutableArray array];
    str =[str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    NSString *EmailregexString = @"[0-9]+[./-][0-9]+[./-][0-9]{2,4}";
    NSArray  *EmailmatchArray   = nil;
    EmailmatchArray = [str componentsMatchedByRegex:EmailregexString];
    if([EmailmatchArray count]>0)
    {
        NSString *emailString=[EmailmatchArray objectAtIndex:0];
        [emailArray addObject:emailString];
    }
    return [EmailmatchArray componentsJoinedByString:@","];
}



-(NSString *)getCounty:(NSMutableArray *)aryResult{
    NSString *country = @"";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", @"county"];
    NSArray* newArray = [aryResult filteredArrayUsingPredicate:predicate];
    if(newArray.count > 0){
        NSArray *aryCounty = [[newArray objectAtIndex:0] componentsSeparatedByString:@" "];
        if(aryCounty.count <= 3){
            int indexCounty = [aryResult indexOfObject:[newArray objectAtIndex:0]];
            if(aryResult.count > indexCounty+1){
                country = [aryResult objectAtIndex:indexCounty+1];
                //                NSLog(@"COUNTY : %@", [country stringByReplacingOccurrencesOfString:@" " withString:@""]);
            }
        }
        else{
            int indexCounty = [aryResult indexOfObject:[newArray objectAtIndex:0]];
            if(aryResult.count > indexCounty+1){
                country = [aryResult objectAtIndex:indexCounty];
                country = [[country uppercaseString] stringByReplacingOccurrencesOfString:@"COUNTY"  withString:@""];
                country = [[country uppercaseString] stringByReplacingOccurrencesOfString:@"OF" withString:@""];
                
                //                country = [[country uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
                
                country = [self getObjectAtIndexinString:country atIndex:0];
                if(country.length <= 3){
                    NSMutableArray *ary = [NSMutableArray arrayWithArray: [country componentsSeparatedByString:@" "]];
                    [ary removeLastObject];
                    country = [self getObjectAtIndexinString:[ary componentsJoinedByString:@" "] atIndex:0];
                }
            }
        }
    }
    else{
        NSPredicate *predicateC = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", @"CITY OF"];
        NSArray* newArray = [aryResult filteredArrayUsingPredicate:predicateC];
        if(newArray.count > 0){
            NSArray *aryCounty = [[newArray objectAtIndex:0] componentsSeparatedByString:@" "];
            if(aryCounty.count <= 4){
                int indexCounty = [aryResult indexOfObject:[newArray objectAtIndex:0]];
                if(aryResult.count > indexCounty-1 && indexCounty-1 > 0){
                    country = [aryResult objectAtIndex:indexCounty-1];
                    //                    NSLog(@"COUNTY : %@", [country stringByReplacingOccurrencesOfString:@" " withString:@""]);
                }
            }
        }
        else{
            NSPredicate *predicateC = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", @"FLORIDA HIGHWAY PATROL"];
            NSArray* newArray = [aryResult filteredArrayUsingPredicate:predicateC];
            if(newArray.count > 0){
                NSArray *aryCounty = [[newArray objectAtIndex:0] componentsSeparatedByString:@" "];
                if(aryCounty.count <= 3){
                    int indexCounty = [aryResult indexOfObject:[newArray objectAtIndex:0]];
                    if(aryResult.count > indexCounty+1 && indexCounty+1 > 0){
                        country = [self getObjectAtIndexinString:[aryResult objectAtIndex:indexCounty+1] atIndex:0];
                    }
                }
            }
            else{
                NSPredicate *predicateC = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", @"FLORIDA UNIFORM"];
                NSArray* newArray = [aryResult filteredArrayUsingPredicate:predicateC];
                if(newArray.count > 0){
                    NSArray *aryCounty = [[newArray objectAtIndex:0] componentsSeparatedByString:@" "];
                    if(aryCounty.count <= 3){
                        int indexCounty = [aryResult indexOfObject:[newArray objectAtIndex:0]];
                        if(aryResult.count > indexCounty+1 && indexCounty+1 > 0){
                            country = [self getObjectAtIndexinString:[aryResult objectAtIndex:indexCounty+1] atIndex:0];
                        }
                    }
                }
                
            }
        }
    }
    return country;
    
}

-(NSString *)getCitation:(NSMutableArray *)aryResult{
    NSString *citation = @"";
//    NSPredicate *regextest = [NSPredicate predicateWithFormat:@"SELF MATCHES '*.([1-9]{2}[.-/][1-9]{2}[.-/][1-9]{2,4}).*'"];
    
    NSPredicate *regextest = [NSPredicate predicateWithFormat:@"SELF CONTAINS '*.([1-9]{2}[.-/][1-9]{2}[.-/][1-9]{2,4}).*'"];

    
    NSArray* prCt = [aryResult filteredArrayUsingPredicate:regextest];
    if(prCt.count > 0)
        citation = [prCt objectAtIndex:0];
    return citation;
}

-(NSString *)getFirstName:(NSMutableArray *)aryResult{
    NSString *fName = @"";
    NSPredicate *preFName = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", @"FIRST"];
    NSArray* newFName = [aryResult filteredArrayUsingPredicate:preFName];
    if(newFName.count > 0){
        int indexFName = [aryResult indexOfObject:[newFName objectAtIndex:0]];
        if([[[newFName objectAtIndex:0] componentsSeparatedByString:@" "] count] > 6){
            if(aryResult.count > indexFName && indexFName >= 0){
                fName = [aryResult objectAtIndex:indexFName];
                NSRange r = [fName rangeOfString:@"FIRST"];
                fName = [fName substringFromIndex:r.location + r.length];
                fName = [self getObjectAtIndexinString:fName atIndex:0];
                
                //                NSLog(@"first name : %@", fName);
            }
        }
        
        else if(aryResult.count > indexFName+1){
            fName = [aryResult objectAtIndex:indexFName+1];
            fName = [self getObjectAtIndexinString:fName atIndex:0];
            
            //            NSLog(@"first name : %@", fName);
        }
    }
    else{
        NSPredicate *preFName = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", @"MIDDLE"];
        NSArray* newFName = [aryResult filteredArrayUsingPredicate:preFName];
        if(newFName.count > 0){
            int indexFName = [aryResult indexOfObject:[newFName objectAtIndex:0]];
            if(aryResult.count > indexFName-1 && indexFName-1 >= 0){
                fName = [aryResult objectAtIndex:indexFName-1];
                fName = [self getObjectAtIndexinString:fName atIndex:0];
                
                //                NSLog(@"first name : %@", fName);
            }
        }
        else{
            NSPredicate *preFName = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", @"MIOOLE"];
            NSArray* newFName = [aryResult filteredArrayUsingPredicate:preFName];
            if(newFName.count > 0){
                int indexFName = [aryResult indexOfObject:[newFName objectAtIndex:0]];
                if(aryResult.count > indexFName-1 && indexFName-1 >= 0){
                    fName = [aryResult objectAtIndex:indexFName-1];
                    fName = [self getObjectAtIndexinString:fName atIndex:0];
                    
                    //                NSLog(@"first name : %@", fName);
                }
            }
            else{
                NSPredicate *preFName = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", @"PRINT"];
                NSArray* newFName = [aryResult filteredArrayUsingPredicate:preFName];
                if(newFName.count > 0){
                    int indexFName = [aryResult indexOfObject:[newFName objectAtIndex:0]];
                    if(aryResult.count > indexFName+1 && indexFName+1 >= 0){
                        fName = [aryResult objectAtIndex:indexFName+1];
                        fName = [self getObjectAtIndexinString:fName atIndex:0];
                        
                        //                NSLog(@"first name : %@", fName);
                    }
                }
                else
                {
                    NSPredicate *preFName = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", @"LAST"];
                    NSArray* newFName = [aryResult filteredArrayUsingPredicate:preFName];
                    if(newFName.count > 0){
                        int indexFName = [aryResult indexOfObject:[newFName objectAtIndex:0]];
                        if([[[newFName objectAtIndex:0] componentsSeparatedByString:@" "] count] > 6){
                            if(aryResult.count > indexFName && indexFName >= 0){
                                fName = [aryResult objectAtIndex:indexFName];
                                fName = [self getObjectAtIndexinString:fName atIndex:0];
                                
                                //                NSLog(@"first name : %@", fName);
                            }
                        }
                        else{
                            {
                                fName = [aryResult objectAtIndex:indexFName+1];
                                if([[fName componentsSeparatedByString:@" "] count]>1){
                                    fName = [self getObjectAtIndexinString:fName atIndex:1];
                                }
                            }
                        }
                    }
                }
            }
            
        }
        
    }
    if([fName isEqualToString:@""]){
        NSPredicate *preFName = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", @"DEFENDANT COPY"];
        NSArray* newFName = [aryResult filteredArrayUsingPredicate:preFName];
        if(newFName.count > 0){
            int indexFName = [aryResult indexOfObject:[newFName objectAtIndex:0]];
            if(aryResult.count > indexFName+1 && indexFName+1 >= 0){
                fName = [aryResult objectAtIndex:indexFName+1];
                fName = [self getObjectAtIndexinString:fName atIndex:0];
                
                //                NSLog(@"first name : %@", fName);
            }
        }
        
    }
    return fName;
}

-(NSString *)getLastName:(NSMutableArray *)aryResult{
    NSString *lName = @"";
    NSPredicate *preLName = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", @"LAST"];
    NSArray* newLName = [aryResult filteredArrayUsingPredicate:preLName];
    if(newLName.count > 0){
        int indexLName = [aryResult indexOfObject:[newLName objectAtIndex:0]];
        if(aryResult.count > indexLName+1){
            lName = [aryResult objectAtIndex:indexLName+1];
            if([[lName componentsSeparatedByString:@" "] count]>1){
                lName = [self getObjectAtIndexinString:lName atIndex:1];
                //                lName = [[lName componentsSeparatedByString:@" "] lastObject];
            }
            //            NSLog(@"last name : %@", lName);
        }
    }
    else{
        NSPredicate *preFName = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", @"FIRST"];
        NSArray* newFName = [aryResult filteredArrayUsingPredicate:preFName];
        if(newFName.count > 0){
            int indexFName = [aryResult indexOfObject:[newFName objectAtIndex:0]];
            if([[[newFName objectAtIndex:0] componentsSeparatedByString:@" "] count] > 6){
                if(aryResult.count > indexFName && indexFName >= 0){
                    lName = [aryResult objectAtIndex:indexFName];
                    NSRange r = [lName rangeOfString:@"FIRST"];
                    lName = [lName substringFromIndex:r.location + r.length];
                    lName = [self getObjectAtIndexinString:lName atIndex:1];
                    
                    //                NSLog(@"first name : %@", fName);
                }
            }
        }
    }
    return lName;
}

-(NSString *)getDateTime:(NSMutableArray *)aryResult{
    NSString *datetime = @"";
    
    NSPredicate *predatetime = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", @"DAY OF"];
    NSArray* newDateTime = [aryResult filteredArrayUsingPredicate:predatetime];
    if(newDateTime.count > 0){
        int indexDTime = [aryResult indexOfObject:[newDateTime objectAtIndex:0]];
        if(aryResult.count > indexDTime+1){
            NSString *strDatetime = [aryResult objectAtIndex:indexDTime+1];
            strDatetime = [strDatetime stringByReplacingOccurrencesOfString:@"|" withString:@""];
            strDatetime = [strDatetime stringByReplacingOccurrencesOfString:@" 1 " withString:@" "];
            //            fName = [self getObjectAtIndexinString:fName atIndex:0];
            NSArray *aryDT = [strDatetime componentsSeparatedByString:@" "];
            int count = 0;
            for (NSString *str in aryDT) {
                if([[str stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""])
                    continue;
                else{
                    datetime = [datetime stringByAppendingFormat:@"%@ ", str];
                    count++;
                    if(count > 4)
                        break;
                }
            }
            datetime = [datetime substringToIndex:datetime.length - 1];
            NSMutableArray *aryDD  = [NSMutableArray arrayWithArray:[datetime componentsSeparatedByString:@" "]];
            [aryDD removeObjectAtIndex:0];
            NSString *strTime = @"";
            if(aryDD.count != 3){
                strTime = [aryDD lastObject];
                [aryDD removeLastObject];
            }
            datetime = [aryDD componentsJoinedByString:@"-"];
            NSLocale* usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en-US"];
            
            NSDateFormatter *dtFormat = [[NSDateFormatter alloc] init];
            if([strTime isEqualToString:@""])
                [dtFormat setDateFormat:@"MM-dd-yyyy"];
            else
                [dtFormat setDateFormat:@"MM-dd-yyyy hh:mm"];
            
            [dtFormat setLocale:usLocale];
            NSDate *dt;
            if([strTime isEqualToString:@""])
                dt = [dtFormat dateFromString:datetime];
            else
                dt = [dtFormat dateFromString:[NSString stringWithFormat:@"%@ %@", datetime, strTime]];
            if(!dt)
                dt = [dtFormat dateFromString:datetime];
            
            NSDateFormatter *dtDisplayFormat = [[NSDateFormatter alloc] init];
            [dtDisplayFormat setDateFormat:@"MMM dd, yyyy hh:mm a"];
            datetime = [dtDisplayFormat stringFromDate:dt];
            if(datetime == nil){
                datetime = @"";
                //                NSLog(@"wrong format");
            }
            
            //            NSLog(@"Date time : %@", datetime);
        }
    }
    if([datetime isEqualToString:@""]){
        NSPredicate *predatetime = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", @"WEEK"];
        NSArray* newDateTime = [aryResult filteredArrayUsingPredicate:predatetime];
        if(newDateTime.count > 0){
            int indexDTime = [aryResult indexOfObject:[newDateTime objectAtIndex:0]];
            if(aryResult.count > indexDTime+1){
                NSString *strDatetime = [aryResult objectAtIndex:indexDTime+1];
                strDatetime = [strDatetime stringByReplacingOccurrencesOfString:@"|" withString:@""];
                //            fName = [self getObjectAtIndexinString:fName atIndex:0];
                NSArray *aryDT = [strDatetime componentsSeparatedByString:@" "];
                int count = 0;
                for (NSString *str in aryDT) {
                    if([[str stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""])
                        continue;
                    else{
                        datetime = [datetime stringByAppendingFormat:@"%@ ", str];
                        count++;
                        if(count > 4)
                            break;
                    }
                }
                datetime = [datetime substringToIndex:datetime.length - 1];
                NSMutableArray *aryDD  = [NSMutableArray arrayWithArray:[datetime componentsSeparatedByString:@" "]];
                [aryDD removeObjectAtIndex:0];
                NSString *strTime = @"";
                if(aryDD.count != 3){
                    strTime = [aryDD lastObject];
                    [aryDD removeLastObject];
                }
                datetime = [aryDD componentsJoinedByString:@"-"];
                NSLocale* usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en-US"];
                
                NSDateFormatter *dtFormat = [[NSDateFormatter alloc] init];
                if([strTime isEqualToString:@""])
                    [dtFormat setDateFormat:@"MM-dd-yyyy"];
                else
                    [dtFormat setDateFormat:@"MM-dd-yyyy hh:mm"];
                [dtFormat setLocale:usLocale];
                NSDate *dt;
                if([strTime isEqualToString:@""])
                    dt = [dtFormat dateFromString:datetime];
                else
                    dt = [dtFormat dateFromString:[NSString stringWithFormat:@"%@ %@", datetime, strTime]];
                if(!dt)
                    dt = [dtFormat dateFromString:datetime];
                NSDateFormatter *dtDisplayFormat = [[NSDateFormatter alloc] init];
                [dtDisplayFormat setDateFormat:@"MMM dd, yyyy hh:mm a"];
                datetime = [dtDisplayFormat stringFromDate:dt];
                if(datetime == nil){
                    datetime = @"";
                }
                
            }
            
        }
        if([datetime isEqualToString:@""]){
            NSPredicate *predatetime = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", @"MONTH "];
            NSArray* newDateTime = [aryResult filteredArrayUsingPredicate:predatetime];
            if(newDateTime.count > 0){
                int indexDTime = [aryResult indexOfObject:[newDateTime objectAtIndex:0]];
                if(aryResult.count > indexDTime+1){
                    NSString *strDatetime = [aryResult objectAtIndex:indexDTime+1];
                    strDatetime = [strDatetime stringByReplacingOccurrencesOfString:@"|" withString:@""];
                    //            fName = [self getObjectAtIndexinString:fName atIndex:0];
                    NSArray *aryDT = [strDatetime componentsSeparatedByString:@" "];
                    int count = 0;
                    for (NSString *str in aryDT) {
                        if([[str stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""])
                            continue;
                        else{
                            datetime = [datetime stringByAppendingFormat:@"%@ ", str];
                            count++;
                            if(count > 4)
                                break;
                        }
                    }
                    datetime = [datetime substringToIndex:datetime.length - 1];
                    
                    NSMutableArray *aryDD  = [NSMutableArray arrayWithArray:[datetime componentsSeparatedByString:@" "]];
                    
                    [aryDD removeObjectAtIndex:0];
                    NSString *strTime = @"";
                    if(aryDD.count != 3){
                        strTime = [aryDD lastObject];
                        [aryDD removeLastObject];
                    }
                    
                    datetime = [aryDD componentsJoinedByString:@"-"];
                    NSLocale* usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en-US"];
                    
                    NSDateFormatter *dtFormat = [[NSDateFormatter alloc] init];
                    if([strTime isEqualToString:@""])
                        [dtFormat setDateFormat:@"MM-dd-yyyy"];
                    else
                        [dtFormat setDateFormat:@"MM-dd-yyyy hh:mm"];
                    [dtFormat setLocale:usLocale];
                    NSDate *dt;
                    if([strTime isEqualToString:@""])
                        dt = [dtFormat dateFromString:datetime];
                    else
                        dt = [dtFormat dateFromString:[NSString stringWithFormat:@"%@ %@", datetime, strTime]];
                    if(!dt)
                        dt = [dtFormat dateFromString:datetime];
                    
                    NSDateFormatter *dtDisplayFormat = [[NSDateFormatter alloc] init];
                    [dtDisplayFormat setDateFormat:@"MMM dd, yyyy hh:mm a"];
                    datetime = [dtDisplayFormat stringFromDate:dt];
                    if(datetime == nil){
                        datetime = @"";
                    }
                    
                }
                
            }
        }
        if([datetime isEqualToString:@""]){
            {
                NSPredicate *predatetime = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", @"DAY YEAR"];
                NSArray* newDateTime = [aryResult filteredArrayUsingPredicate:predatetime];
                if(newDateTime.count > 0){
                    int indexDTime = [aryResult indexOfObject:[newDateTime objectAtIndex:0]];
                    if(aryResult.count > indexDTime+1){
                        NSString *strDatetime = [aryResult objectAtIndex:indexDTime+1];
                        //            fName = [self getObjectAtIndexinString:fName atIndex:0];
                        NSArray *aryDT = [strDatetime componentsSeparatedByString:@" "];
                        int count = 0;
                        for (NSString *str in aryDT) {
                            if([[str stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""])
                                continue;
                            else{
                                datetime = [datetime stringByAppendingFormat:@"%@ ", str];
                                count++;
                                if(count > 4)
                                    break;
                            }
                        }
                        datetime = [datetime substringToIndex:datetime.length - 1];
                        NSMutableArray *aryDD  = [NSMutableArray arrayWithArray:[datetime componentsSeparatedByString:@" "]];
                        [aryDD removeObjectAtIndex:0];
                        NSString *strTime = @"";
                        if(aryDD.count != 3){
                            strTime = [aryDD lastObject];
                            [aryDD removeLastObject];
                        }
                        
                        datetime = [aryDD componentsJoinedByString:@"-"];
                        NSLocale* usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en-US"];
                        
                        NSDateFormatter *dtFormat = [[NSDateFormatter alloc] init];
                        if([strTime isEqualToString:@""])
                            [dtFormat setDateFormat:@"MM-dd-yyyy"];
                        else
                            [dtFormat setDateFormat:@"MM-dd-yyyy hh:mm"];
                        [dtFormat setLocale:usLocale];
                        NSDate *dt;
                        if([strTime isEqualToString:@""])
                            dt = [dtFormat dateFromString:datetime];
                        else
                            dt = [dtFormat dateFromString:[NSString stringWithFormat:@"%@ %@", datetime, strTime]];
                        if(!dt)
                            dt = [dtFormat dateFromString:datetime];
                        
                        NSDateFormatter *dtDisplayFormat = [[NSDateFormatter alloc] init];
                        [dtDisplayFormat setDateFormat:@"MMM dd, yyyy hh:mm a"];
                        datetime = [dtDisplayFormat stringFromDate:dt];
                        if(datetime == nil){
                            datetime = @"";
                        }
                        
                    }
                    
                }
            }
        }
    }
    
    if([datetime isEqualToString:@""]){
        NSString *month = @"";
        NSPredicate *preMonth = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", @"MONTH"];
        NSArray* aryMonth = [aryResult filteredArrayUsingPredicate:preMonth];
        if(aryMonth.count > 0){
            int index = [aryResult indexOfObject:[aryMonth objectAtIndex:0]];
            if(aryResult.count > index+1 && index+1 > 0){
                month = [aryResult objectAtIndex:index+1];
            }
        }
        
        NSString *day = @"";
        NSPredicate *preday = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", @"DAY"];
        NSArray* aryday = [aryResult filteredArrayUsingPredicate:preday];
        if(aryday.count > 0){
            int index = [aryResult indexOfObject:[aryday objectAtIndex:0]];
            if(aryResult.count > index+1 && index+1 > 0){
                day = [aryResult objectAtIndex:index+1];
            }
            if([day intValue] == 0){
                if(aryday.count >= 2){
                    int index = [aryResult indexOfObject:[aryday objectAtIndex:1]];
                    if(aryResult.count > index+1 && index+1 > 0){
                        day = [aryResult objectAtIndex:index+1];
                    }
                    if([day intValue] == 0){
                        if(aryday.count >= 3){
                            int index = [aryResult indexOfObject:[aryday objectAtIndex:2]];
                            if(aryResult.count > index+1 && index+1 > 0){
                                day = [aryResult objectAtIndex:index+1];
                            }
                            
                        }
                    }
                }
            }
        }
        
        NSString *year = @"";
        NSPredicate *preyear = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", @"YEAR"];
        NSArray* aryyear = [aryResult filteredArrayUsingPredicate:preyear];
        if(aryyear.count > 0){
            int index = [aryResult indexOfObject:[aryyear objectAtIndex:0]];
            if(aryResult.count > index+1 && index+1 > 0){
                year = [aryResult objectAtIndex:index+1];
            }
            if([year intValue] == 0){
                if(aryyear.count >= 2){
                    int index = [aryResult indexOfObject:[aryyear objectAtIndex:1]];
                    if(aryResult.count > index+1 && index+1 > 0){
                        year = [aryResult objectAtIndex:index+1];
                    }
                    if([year intValue] == 0){
                        if(aryyear.count >= 3){
                            int index = [aryResult indexOfObject:[aryyear objectAtIndex:2]];
                            if(aryResult.count > index+1 && index+1 > 0){
                                year = [aryResult objectAtIndex:index+1];
                            }
                            
                        }
                    }
                }
            }
        }
        
        NSLocale* usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en-US"];
        datetime = [NSString stringWithFormat:@"%@-%@-%@", month, day, year];
        NSDateFormatter *dtFormat = [[NSDateFormatter alloc] init];
        [dtFormat setDateFormat:@"MM-dd-yyyy"];
        [dtFormat setLocale:usLocale];
        NSDate *dt = [dtFormat dateFromString:datetime];
        
        NSDateFormatter *dtDisplayFormat = [[NSDateFormatter alloc] init];
        [dtDisplayFormat setDateFormat:@"MMM dd, yyyy hh:mm a"];
        datetime = [dtDisplayFormat stringFromDate:dt];
        if(datetime == nil){
            datetime = @"";
        }
        
    }
    return datetime;
}

-(NSString *)getStatute:(NSMutableArray *)aryResult{
    NSString *statute = @"";
    NSPredicate *preStatute = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", @"Sub-section"];
    NSArray* statue = [aryResult filteredArrayUsingPredicate:preStatute];
    if(statue.count > 0){
        NSString *strStatue = [statue objectAtIndex:0];
        if([strStatue componentsSeparatedByString:@" "].count > 2){
            statute = [self getObjectAtIndexinString:strStatue atIndex:1];
        }
        else{
            int index = [aryResult indexOfObject:[statue objectAtIndex:0]];
            if(aryResult.count > index-1 && index-1 > 0){
                statute = [aryResult objectAtIndex:index-1];
            }
        }
        //            NSLog(@"statute : %@", statute);
    }
    else{
        NSPredicate *preStatute1 = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", @"SECTION"];
        NSMutableArray* statue1 = [NSMutableArray arrayWithArray: [aryResult filteredArrayUsingPredicate:preStatute1]];
        if(statue1.count > 0){
            int index = [aryResult indexOfObject:[statue1 objectAtIndex:0]];
            if([[statue1 objectAtIndex:0] componentsSeparatedByString:@" "].count > 2){
                statute =  [self getObjectAtIndexinString:[statue1 objectAtIndex:0] atIndex:1];
                if([statute rangeOfString:@"SECTION"].location != NSNotFound){
                    NSMutableArray *ary = [NSMutableArray arrayWithArray: [[statue1 objectAtIndex:0] componentsSeparatedByString:@" "]];
                    [ary removeLastObject];
                    statute = [ary componentsJoinedByString:@" "];
                    statute =  [self getObjectAtIndexinString:statute atIndex:1];
                }
            }
            else{
                if(aryResult.count > index+1 && index+1 > 0){
                    statute = [aryResult objectAtIndex:index+1];
                }
            }
        }
        
    }
    return statute;
}



-(NSString *)getObjectAtIndexinString:(NSString *)strInput atIndex:(int)index{
    NSString *strResult = @"";
    NSMutableArray *arySS = [NSMutableArray arrayWithArray: [strInput componentsSeparatedByString:@" "]];
    if(index == 1){
        while(1){
            if(([[arySS lastObject] isEqualToString:@""] || [[arySS lastObject] isEqualToString:@" "]))
                [arySS removeLastObject];
            else{
                strResult = [arySS lastObject];
                //            NSLog(@"strTResult '%@'", strResult);
                //            NSLog(@"statute : %@", strResult);
                break;
            }
        }
    }
    else{
        while(1){
            if(([[arySS objectAtIndex:0] isEqualToString:@""] || [[arySS objectAtIndex:0] isEqualToString:@" "]))
                [arySS removeObjectAtIndex:0];
            else{
                strResult = [arySS objectAtIndex:0];
                //                NSLog(@"strTResult '%@'", strResult);
                //                NSLog(@"statute : %@", strResult);
                break;
            }
        }
    }
    return strResult;
}


- (IBAction)PreRotation:(id)sender {
    
    self.processedImage=[imageProcessor processRotation:[self processedImage]];
    self.resultView.image=[self processedImage];
}

- (IBAction)PreHistogram:(id)sender {
    
    self.processedImage=[imageProcessor processHistogram:[self processedImage]];
    self.resultView.image=[self processedImage];
}

- (IBAction)PreFilter:(id)sender {
    
    self.processedImage=[imageProcessor processFilter:[self processedImage]];
    self.resultView.image=[self processedImage];
}

- (IBAction)PreBinarize:(id)sender {
    
    self.processedImage=[imageProcessor processBinarize:[self processedImage]];
    self.resultView.image=[self processedImage];
}

- (IBAction)returnOriginal:(id)sender {
    
    self.processedImage=[self takenImage ];
    self.resultView.image= [self takenImage];
}
                       
                       
- (IBAction)TakePhoto:(id)sender {
    mediaPicker = [[UIImagePickerController alloc] init];
    mediaPicker.delegate=self;
    mediaPicker.allowsEditing = YES;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:
                                      @"Take a photo or choose existing, and use the control to center the announce"
                                                                 delegate: self                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Take photo", @"Choose Existing", nil];
        [actionSheet showInView:self.view];
    } else {
        mediaPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;     
        [self presentModalViewController:mediaPicker animated:YES];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex != actionSheet.cancelButtonIndex)
    {
        if (buttonIndex == 0) {
            mediaPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        } else if (buttonIndex == 1) {
            mediaPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        
        [self presentModalViewController:mediaPicker animated:YES];
    }
    
    else [self dismissModalViewControllerAnimated:YES]; 
    
    
}

- (UIView*)CreateOverlay{
    
    UIView *overlay= [[UIView alloc] 
                      initWithFrame:CGRectMake
                      (0, 0, self.view.frame.size.width, self.view.frame.size.height*0.10)];//width equal and height 15%
    overlay.backgroundColor=[UIColor blackColor];
    overlay.alpha=0.5;
    
    return overlay;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    [picker dismissModalViewControllerAnimated:YES];
    
    //I take the coordinate of the cropping
    CGRect croppedRect=[[info objectForKey:UIImagePickerControllerCropRect] CGRectValue];

    UIImage *original=[info objectForKey:UIImagePickerControllerOriginalImage];
   

    UIImage *rotatedCorrectly;
    
    if (original.imageOrientation!=UIImageOrientationUp)
    rotatedCorrectly=[original rotate:original.imageOrientation];
    else rotatedCorrectly=original;
    

    CGImageRef ref= CGImageCreateWithImageInRect(rotatedCorrectly.CGImage, croppedRect);
    self.takenImage= [UIImage imageWithCGImage:ref];
    self.resultView.image=[self takenImage];
     self.processedImage=[self takenImage ];
    process.hidden=NO;
    BinarizeButton.hidden=NO;
    Histogrambutton.hidden=NO;
    FilterButton.hidden=NO;
    rotateButton.hidden=NO;
        self.read.hidden=NO;    
    originalButton.hidden=NO;
    
}

@end
