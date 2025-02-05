# InterviewExercise

## Description
This project loads and displays recipes using the DummyJSON API and follows the MVVM architectural pattern.

## Main Features
- **Feature 1: Fetch and Display a List** - Fetches and displays a list of recipes using the [DummyJSON API](https://dummyjson.com/docs).
- **Feature 2: Item Detail View** - Users can tap a recipe to navigate to a detailed view, which displays additional information.

## Additional Features
- Uses **Dependency Injection** for the network service.
- **pull-to-refresh** functionality.
- **pagination** for HomeView.
- **search** recipe.
- Enhances UI with **animations and styling**.

## Not Implemented (TO DO)
- **Sorting** the Recipes list based on API data.

## Installation Instructions
### Clone the Repository
```sh
# Clone the repository
git clone https://github.com/yourusername/InterviewExercise.git

# Navigate to the project directory
cd InterviewExercise

# Open the project in Xcode
open InterviewExercise.xcodeproj
```

### Dependencies
This project uses **Swift Package Manager (SPM)** to manage dependencies. Xcode will automatically fetch the required packages.

## Architecture & Libraries
- **Architecture**: MVVM
- **Dependency**: [Kingfisher](https://github.com/onevcat/Kingfisher) for image loading and caching

## Contributors
Developed by **Ramadan Alharahsheh** as part of a technical assessment.
