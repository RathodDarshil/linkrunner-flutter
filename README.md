# linkrunner

Flutter Package for [linkrunner.io](https://www.linkrunner.io)

## Installation

### Step 1: Installing linkrunner

#### Installing through cmdline

run the following:

```sh
flutter pub add linkrunner
```

#### OR

#### Manually adding dependencies

Add `linkrunner` to your `pubspec.yaml` under dependencies:

```yaml
dependencies:
    linkrunner: ^0.5.4
```

Then run:

```sh
flutter pub get
```

to install your new dependency.

## Usage

### Initialisation

You will need your [project token](https://www.linkrunner.io/dashboard?m=documentation) to initialise the package.

Place it in the `main` function:

```dart
import 'package:linkrunner/main.dart';

// Initialize the package
final linkrunner = LinkRunner();

void main() async {
    // Call the .ensureInitialized method before calling the .init method
    WidgetsFlutterBinding.ensureInitialized();

    final init = await lr.init("YOUR_PROJECT_TOKEN");
    runApp(MyApp());
}
```

#### Response type for `linkrunner.init`

```
{
  ip_location_data: {
    ip: string;
    city: string;
    countryLong: string;
    countryShort: string;
    latitude: number;
    longitude: number;
    region: string;
    timeZone: string;
    zipCode: string;
  };
  deeplink: string;
  root_domain: boolean;
}
```

### Trigger

Call this function once your onboarding is completed and the main stack is loaded

```dart
import 'package:linkrunner/main.dart';

void trigger() async {
    final trigger = await linkrunner.trigger(
        userData: LRUserData(
        id: '1',
        name: 'John Doe', // optional
        phone: '9583849238', // optional
        email: 'support@linkrunner.io', //optional
        ),
        data: {}, // Any other data you might need
    );
  }
```

You can pass any additional user related data in the `data` attribute

#### Response type for `linkrunner.trigger`

```
{
  ip_location_data: {
    ip: string;
    city: string;
    countryLong: string;
    countryShort: string;
    latitude: number;
    longitude: number;
    region: string;
    timeZone: string;
    zipCode: string;
  };
  deeplink: string;
  root_domain: boolean;
  trigger: boolean; // Deeplink won't be triggered if false
}
```

Note: Value of `trigger` will be only true for the first time the function is triggered by the user in order to prevent unnecessary redirects

### Facing issues during integration?

Email us at support@linkrunner.io

## License

MIT
