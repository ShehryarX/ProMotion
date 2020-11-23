# ProMotion

## Preview
[Devpost](https://devpost.com/software/promotion) \
[Video Demo](https://youtu.be/Z5VNDa7FNNA) 

![Preview GIF](https://github.com/rafitj/ProMotion/blob/main/ProMotionImages/PromotionPreview.gif?raw=true)


## Description

2020 has been a difficult year for all of us. It’s been a year full of bad news, boredom, isolation and a disconnect from friends and the community. The pandemic has forced us to spend most of the year in isolation and for the most part has negatively impacted both mental and physical wellbeing. We seem to have forgotten what day of the week it is and every day feels repetitive and mundane.

ProMotion is here to change that. We have a platform that allows you to use machine learning and augmented reality to connect with your community and make mundane tasks fun. We have created an IOS application that gives you instant feedback and helps you better yourself by correcting your form and tracking your progress in many sports such as adjusting your jump shot form in basketball and spike form in volleyball.

## Design & Development

This is done through bleeding edge tech and the latest machine learning technologies available from Apple including ML kit and reality kit.

At a high level, we begin by training a machine learning model on specific action sequences.  For example, a jump shot in basketball. From there we train and learn what the ideal movements for this action are. For a jump shot, we may want to train on highlights of NBA players. We can then record a user completing this specific action and capture key pivot points on their body such as their knees, elbows and wrists. We compare these pivot points to those of the ideal model and can compute the difference. Lower levels of difference results in higher scores which is signified by the user’s rating on the top right of the screen. The user can record themselves completing any action and has the ability to playback their video and view the change in their rating over time.

More specifically, getting into the technical details behind it, the tech stack is implemented as follows:
- MLKit along with the vision framework running PoseNET, a human body pose detector to capture 17 different body landmarks (wrists, ankles, knees, elbows, etc.) and perform the motion tracking. This happens live on device running at 60fps, an incredibly difficult feat
- This captured body landmark data is then fed to CreateML, where another neural network classifier classifies several types of actions (e.g. for volleyball, what a spike is, for basketball, what a jump shot is)
- Additional body landmark data is captured from reference ideal videos, including NBA highlights, etc. to give us ideal comparison models to evaluate the user’s poses against, giving us a comprehensive rating system
- Next, we had to map the comparison model to the user’s model when actually executing in app in both the time and spatial dimensions, as some people are taller and slightly different in other dimensions as well. This was a huge pain point, as we had to dynamically scale our ideal reference data.
- Finally, tying it all together we had to visualize everything, including the error/difference regions. This required us writing custom renderers drawing out the wireframe in a series of bezier paths, along with freeform polygons to visualize the error regions. Getting this right and visually appealing was quite a challenge.


## Key Features

### Practice Mode

It's been difficult to stay in shape mentally and physically and we all know that physical exercise alone can get mundane. Practice gets boring, there is no stimuli, no one to cheer you on and no way to track your progress. We recognize these major issues and ProMotion’s practice mode completely changes the game. In this mode, users can select from a large number of sports and practice essential skills and moves. There is an interactive UI in augmented reality which provides instant feedback about your form and your progress by comparing your moves to an ideal athlete. 

### Challenge Mode

Our disconnect from our friends and community is easy to miss in these tough times. Even completing the simplest of tasks is a blast when doing it with those you care about. ProMotion’s challenge mode allows users to record their practices, share their progress and compete with friends. 

See how you stack up against your buddies on the leaderboard and share the fun of physical activity with your friend group. Friend’s can easily share, post their attempts and you can replay them in augmented reality.

### Custom Challenges

As we’ve been alluding to, ProMotion isn’t only for athletes. The pandemic has effected everyone and ProMotion is here to help. We take our features one step further by allowing users to create custom motion instantly in our Create mode. Simply name your activity and submit a few video clips to train our ML action classifier. 

Then instantly share your motion and let your friends hop on the trend. No action is too simple, even brushing your teeth or drinking water can be made into a fun activity. COVID has made everything mundane and ProMotion is rolling it back. 

Furthermore, for those looking for more practical use of create modes, we help remote teachers and instructors evaluate and assess their students. Record complex yoga moves or workout techniques and share with your class to help them from a distance. They can practice these moves on their own time and compare themselves to your example.

## What's Next for ProMotion

We plan to add even more functionality like commenting on your friends video or competing with them in real time. The sky is truly the limit with ProMotion.
