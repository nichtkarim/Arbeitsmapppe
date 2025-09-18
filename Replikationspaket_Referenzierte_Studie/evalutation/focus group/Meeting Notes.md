### Understanding Their Current Practices - Experience with UX in Development

- **"Can you describe your current team?"**
  - 6 people in 2-person teams:
    - UI/UX
    - Coders: Siri, OCR, Object Detection
    - Website, deliverables & customer contact

- **"What was your approach to combining UX into your development workflow?"**
  - Initially UI/UX -> Figma Clickdummy -> Waterfall approach
  - Layout and colors for programming taken from the Clickdummy.
  - The Clickdummy served as a basis; the design remained largely the same. The Clickdummy was later no longer used, and new features were directly implemented in the code.
  - Requirements analysis document had to be submitted before starting programming.

- **"Did you face any challenges in combining UX into your development workflow?"**
  - Navigation flow collided with UX requirements.
  - A navigation header designed in the Clickdummy was difficult to implement.
  - Swipe gestures had to be manually programmed.

- **"Did you conduct any usability evaluations?"**
  - Three meetings:
    - Requirements analysis with public transport company.
    - First and second meetings via Zoom with public transport company and representatives of people with disabilities.

- **Presentation of the App**
  - Currently: Usability evaluation through Testflight with 10-15 testers, including public transport company and the german association for the blind.

### Introducing UX-LLM

#### Demonstration of UX-LLM with DepartureBoardStickyView

- **First Impressions**
  - **"On a scale of 1 to 4, how would you rate your initial impression of UX-LLM when it comes to improving the quality of an app's user experience?"**
    - 2, 2, 3
  - **"Based on what you've seen, what are your initial thoughts about UX-LLM?"**
    - Offers new perspectives.
    - Contains good ideas and stimulates thinking and reflection.
      - “I appreciate the fresh perspectives it offers. Even some of the incorrect usability issues are valuable as they make me reevaluate design decisions”
    - Some issues generic, and not applicable to everything.
    - Difficult with single-view granularity, as some details are missing from the flow, e.g., adjustable text size not recognized.
      - “Some issues feel a bit generic and some don’t make sense, since they are addressed in previous screens”

### Deep Dive into UX-LLM's Utility

#### Show prepared Usability Issues from UX-LLM about their app

- **Impressions on predicted Usability Issues**
  - **"On a scale of 1 to 4, how useful do you find these usability issues?"**
    - 4, 3, 3
  - **"What are your initial thoughts about the usability issues identified by UX-LLM?"**
    - Some very helpful, not obvious.
    - Some issues can be added to task board.
      - “directly be imported as to-dos on our task board”
    - Helpful when suspecting something is not optimal, to get another opinion.
      - “On some screens we assumed something is not ideal, but we did not know what the problem was, these issues are very helpful”
  - **"How would you compare the filtered vs. unfiltered usability issues?"**
    - The filtered ones are better and more convinient to use.
    - Unfiltered includes some useless, incorrect, and intended content.

- **Impact on Development Process**
  - **"On a scale of 1 to 4, how much do you believe UX-LLM could improve your development process?"**
    - 2, 3, 4
  - **"In what ways do you think a tool like UX-LLM could impact your development process?"**
    - Quickly obtain a lot of information and filter out unnecessary content quickly.
      - “It’s great to see an overview of what’s available; you can quickly eliminate unnecessary issues and reflect on them”
    - Encourages discussions and meetings.
    - Time-saving compared to manual search.
      - “In the end, it saves a lot of time as it is easier than conducting usability evaluations ourselves”
    - Useful in situations where help or review is needed.

- **Ease of Integration of UX-LLM into current workflow**
  - **"On a scale of 1 to 4, how easy do you think it would be to integrate UX-LLM into your existing development workflow?"**
    - 2, 3, 3
  - **"How would you go about integrating UX-LLM into your workflow, and what factors do you think would make this easy or challenging?"**
    - In a 6-person team, one team member can easily integrate the app into the workflow.
      - “Personally, I wouldn’t mind using the tool, as I, being the project manager, could regularly use UX-LLM and incorporate its findings into our task board”
    - More challenging when working alone under stress without time and resources.

### Discussion and Closing

- **Perceived Limitations / Concerns**
  - **"In general, what did you like about UX-LLM?"**
    - Identification of some unrecognized problems.
    - Encouragement for improvements.
  - **"Do you see any limitations or concerns with using UX-LLM for usability evaluations?"**
    - Under time pressure.
    - Can negatively affect motivation.
    - Generating usability issues is additional work.
      - “I’m a laid-back person, so it would annoy me to have to use another application beside my IDE. I’m not sure if I’d regularly go through these ∼10 points”
    - Could have hardware limitations, e.g., with Vision, Siri, haptic feedback.
    - LLM could have limitations, e.g. alcohol is illegal in some countries.

- **Suggestions for Improvement**
  - **"What improvements or additional features would you suggest for UX-LLM?"**
    - Image generation of a solution proposal in the screenshot for usability issues.
    - IDE Plugin & App Context extraction from code/repo.
      - “just makes sense, as Xcode10 already has the view’s preview and code side by side”
    - Improvement of filtering useless usability issues.
    - Holistic app analysis to find overarching inconsistencies and navigation problems and to generate fewer useless issues that are solved in other views.

- **Additional Comments**
  - **"Do you have any other comments or thoughts you would like to share about UX in app development or about UX-LLM?"**
    - Detailed solution approaches to the problems would be good. For example, color contrast criticism is not understandable because the contrast is high enough.
      - “When it criticized the accessibility of the colors, it would be nice if it could also show what colors to use instead”.