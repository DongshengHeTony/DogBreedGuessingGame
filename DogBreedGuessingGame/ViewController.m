//
//  ViewController.m
//  DogBreedGuessingGame
//
//  Created by 李响 on 2024/5/17.
//

#import "ViewController.h"
#import "NetworkService.h"
#import <SDWebImage/SDWebImage.h>

@interface ViewController ()

@property(nonatomic, strong) UIImageView *dogImageView;
@property(nonatomic, strong) NSMutableArray *choiceButtons;
@property(nonatomic, assign) int numberOfChoices;

@property(nonatomic, strong) NSArray *allDogBreeds;
@property(nonatomic, assign) int currentCorrectIndex;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.numberOfChoices = 3; // assuming we give user 3 choices
    [self setUpViews];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    [self getAllBreed];
}


- (void)getAllBreed {
    [[NetworkService sharedNetworkService] GETRequestWithUrl:@"https://dog.ceo/api/breeds/list/all" paramaters:nil successBlock:^(NSData *  _Nonnull data, NSURLResponse * _Nonnull response) {
        if (data) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if (dic) {
                NSDictionary *message = [dic objectForKey:@"message"];
                if (message.allKeys.count > 0) {
                    self.allDogBreeds = message.allKeys;
                    [self getRandomBreed];
                } else {
                    [self showAllBreedAlert];
                }
            } else {
                [self showAllBreedAlert];
            }
        }
    } FailBlock:^(NSError * _Nonnull error) {
        [self showAllBreedAlert];
    }];
}

- (void)getRandomBreed {
    NSMutableArray *allBreeds = [NSMutableArray arrayWithArray:self.allDogBreeds];
    NSMutableArray *choiceArray = [[NSMutableArray alloc] init];
    NSString *currentCorrectBreed;
    self.currentCorrectIndex = arc4random_uniform((u_int32_t)self.numberOfChoices);
    
    for (int i = 0; i < self.numberOfChoices; i++) {
        NSUInteger randomIndex = arc4random_uniform((u_int32_t)allBreeds.count);
        NSString *randomBreed = [allBreeds objectAtIndex:randomIndex];
        [allBreeds removeObjectAtIndex:randomIndex];
        if (i == self.currentCorrectIndex) {
            currentCorrectBreed = randomBreed;
        }
        [choiceArray addObject:randomBreed];
        UIButton *btn = [self.choiceButtons objectAtIndex: i];
        [btn setTitle:randomBreed forState:UIControlStateNormal];
    }
    
    
    [[NetworkService sharedNetworkService] GETRequestWithUrl: [NSString stringWithFormat:@"https://dog.ceo/api/breed/%@/images/random", currentCorrectBreed] paramaters:nil successBlock:^(NSData *  _Nonnull data, NSURLResponse * _Nonnull response) {
        if (data) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if (dic) {
                NSString *imageURL = [dic objectForKey:@"message"];
                if (imageURL) {
                    [self.dogImageView sd_setImageWithURL:[NSURL URLWithString:imageURL]];
                } else {
                    [self showRandomBreedAlert];
                }
            } else {
                [self showRandomBreedAlert];
            }
        }
    } FailBlock:^(NSError * _Nonnull error) {
        [self showRandomBreedAlert];
    }];
}


- (void)showAllBreedAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Fail to get all breeds." message:@"Please try again." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *tryAgain = [UIAlertAction actionWithTitle:@"Try again." style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getAllBreed];
    }];
    [alert addAction:tryAgain];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });
}


- (void)showRandomBreedAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Fail to get random breed." message:@"Please try again." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *tryAgain = [UIAlertAction actionWithTitle:@"Try again." style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getRandomBreed];
    }];
    [alert addAction:tryAgain];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });
}


- (void)setUpViews {
    [self.dogImageView.topAnchor constraintEqualToAnchor: self.view.safeAreaLayoutGuide.topAnchor].active = YES;
    [self.dogImageView.leadingAnchor constraintEqualToAnchor: self.view.leadingAnchor].active = YES;
    [self.dogImageView.trailingAnchor constraintEqualToAnchor: self.view.trailingAnchor].active = YES;
    
    UIButton *firstButton = (UIButton *)self.choiceButtons.firstObject;
    if (firstButton) {
        [firstButton.topAnchor constraintEqualToAnchor:self.dogImageView.bottomAnchor constant:10].active = YES;
        [firstButton.leadingAnchor constraintEqualToAnchor: self.view.leadingAnchor].active = YES;
        [firstButton.trailingAnchor constraintEqualToAnchor: self.view.trailingAnchor].active = YES;
        [firstButton.heightAnchor constraintEqualToConstant:36.0].active = YES;
    }
    if (self.numberOfChoices > 1) {
        for (int i = 1; i < self.numberOfChoices; i++) {
            UIButton *preBtn = (UIButton *)[self.choiceButtons objectAtIndex:i-1];
            UIButton *currentBtn = (UIButton *)[self.choiceButtons objectAtIndex:i];
            if (preBtn && currentBtn) {
                [currentBtn.topAnchor constraintEqualToAnchor:preBtn.bottomAnchor constant:10].active = YES;
                [currentBtn.leadingAnchor constraintEqualToAnchor: self.view.leadingAnchor].active = YES;
                [currentBtn.trailingAnchor constraintEqualToAnchor: self.view.trailingAnchor].active = YES;
                [currentBtn.heightAnchor constraintEqualToConstant:36.0].active = YES;

            }
        }
    }
    UIButton *lastButton = (UIButton *)self.choiceButtons.lastObject;
    if (lastButton) {
        [lastButton.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor].active = YES;
    }
    
}

- (UIImageView *)dogImageView {
    if(_dogImageView == nil) {
        _dogImageView = [[UIImageView alloc] init];
        _dogImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _dogImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview: _dogImageView];
    }
    return _dogImageView;
}

- (NSMutableArray *)choiceButtons {
    if(_choiceButtons == nil){
        _choiceButtons = [[NSMutableArray alloc] init];
        for (int i = 0; i < self.numberOfChoices; i++) {
            UIButton *button = [[UIButton alloc] init];
            button.translatesAutoresizingMaskIntoConstraints = NO;
            [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
            button.tag = i;
            [button addTarget:self action:@selector(choiceButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview: button];
            [_choiceButtons addObject:button];
        }
    }
    return _choiceButtons;
}

- (void)choiceButtonTapped:(UIButton *)button {
    [self showResultAlert:button.tag == self.currentCorrectIndex];
}

- (void)showResultAlert:(BOOL)isCorrect {
    NSString *title = isCorrect ? @"Congratulations!" : @"Sorry.";
    NSString *message = isCorrect ? @"Try next!" : @"You are wrong.";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = isCorrect ? [UIAlertAction actionWithTitle:@"Next" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getRandomBreed];
    }] : [UIAlertAction actionWithTitle:@"Try again." style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { }];
    [alert addAction:action];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });
}
@end
