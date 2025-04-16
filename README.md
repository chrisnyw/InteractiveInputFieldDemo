# InteractiveInputFieldDemo

A brief description of your iOS project. Explain the purpose and main features of the app.

## Prerequisites
Ensure you have the following installed:
- Xcode 16.2 or later
- iOS 18.2 SDK or later
- Swift 6.0 or later

## Getting Started
Clone the repository:
```bash
git clone https://github.com/chrisnyw/InteractiveInputFieldDemo.git
cd InteractiveInputFieldDemo
```

## Setup Instructions
1. Open the project in Xcode:
   ```bash
   open InteractiveInputField.xcodeproj
   ```

2. Select the target device or simulator in Xcode.

![Select Target and Device](./Screenshots/SelectTargetAndDevice.jpg)

## Build and Run
1. Ensure the correct scheme is selected.
2. Click the **Run** button in Xcode or use the shortcut:
   ```
   Command + R
   ```
3. The app should launch in the simulator or connected device.

## Demonstratoin

### Video

<figure>
<img src="https://github.com/user-attachments/assets/a74e44fd-5982-4468-a07e-924757d366c9" width="200" title="Interactive Input Field Demo" alt="Interactive Input Field Demo"/>
</figure>

### Screenshots

#### Idle State

Shows a text input field with placeholder "Start Typing..." with two buttons at the bottom.

<img src="./Screenshots/Idle.png" width="200" title="Idle" alt="Idle"/>

#### Text Input Field Properties

1. When text field got focused

<img src="./Screenshots/TextEmpty.png" width="200" title="Text Empty" alt="Text Empty"/>

2. The initial font size set to 18px (maximum font size)

<img src="./Screenshots/TextFont18.png" width="200" title="TextFont18" alt="TextFont18"/>

3. The font size reduces to 16px if the text occupies 2/3 of text input height

<img src="./Screenshots/TextFont16.png" width="200" title="TextFont16" alt="TextFont16"/>

4. The font size reduces to 14px (minimum font size) if the text occupies 2/3 of text input height again

<img src="./Screenshots/TextFont14.png" width="200" title="TextFont14" alt="TextFont14"/>

5. Text field is able to scroll when continuing add more texts

<img src="./Screenshots/TextFont14WithScroll.png" width="200" title="TextFont14WithScroll" alt="TextFont14WithScroll"/>

#### Fullscreen Text Input Field

When tapping of the expand button next to the input text field, will enter to fullscreen text editing mode

<img src="./Screenshots/TextFullScreen.png" width="200" title="Text FullScreen" alt="Text FullScreen"/>

#### Photo Selection Properties

1. When pressing the photo icon on the bottom-left corner, the app shows the mini photo selection view

<img src="./Screenshots/PhotoPickerBottom.jpg" width="200" title="Photo picker bottom view" alt="Photo picker bottom view"/>

2. Scroll up the bottom mini photo selection view, the app will show all the photos stored in your iPhone

<img src="./Screenshots/PhotoPickerFullScreen.jpg" width="200" title="Photo picker fullscreen" alt="Photo picker fullscreen"/>

3. Clicked on one of the photo, the selected image will show between the input text field and the button like this:

<img src="./Screenshots/PhotoSelected.png" width="200" title="Photo selected" alt="Photo selected"/>

## Happy coding!
