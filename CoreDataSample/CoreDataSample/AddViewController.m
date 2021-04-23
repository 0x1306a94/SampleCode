//
//  AddViewController.m
//  CoreDataSample
//
//  Created by king on 2021/4/21.
//

#import "AddViewController.h"

#import "DBController.h"

#import "Person+CoreDataClass.h"

@interface AddViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *ageTextField;

@end

@implementation AddViewController

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (IBAction)addButtonAction:(UIButton *)sender {

	NSString *name = self.nameTextField.text;
	int16_t age    = self.ageTextField.text.intValue;

	[[[DBController shared] backgroundContext] sd_performChanges:^(NSManagedObjectContext *_Nonnull ctx) {
		Person *person = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:ctx];

		person.name = name;
		person.age  = age;
	}];
}

@end

