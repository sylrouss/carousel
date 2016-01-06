#import "ViewController.h"
#import "CarouselSampleView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CarouselSampleView *carouselSampleView = [[CarouselSampleView alloc] initWithFrame: self.view.frame];
    [self.view addSubview: carouselSampleView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
