//
//  MockedPreviewHelper.swift
//  UXLLM under the MIT License (MIT)
//  
//
//  Created on 16.01.24.
//

import LLMCaller

// For testing purposes like view previews, as it would not be clean to have View's communicate to outer services like LLMCaller
struct MockedUsabilityIssuesLLMHelper {
    
    static let mockedUsabilityIssues =
"""
1. The font size is excessively small, which makes the text difficult to read and can strain the eyes of the viewer.

2. The color scheme is inconsistent and poorly implemented, leading to a confusing and ineffective visual hierarchy that fails to guide the user's attention properly.

3. The layout is not responsive, causing significant issues and a subpar viewing experience on devices with different screen sizes.

4. Navigation throughout the site is overly complicated and unintuitive, leading to user confusion and a decrease in the overall usability of the site.

5. There is a noticeable lack of accessibility options, such as support for screen readers, which makes the site difficult or impossible to use for users with certain disabilities.

6. Users experience slow loading times, which can be frustrating and negatively affect the overall user experience and satisfaction.

7. The interface is overloaded with an excessive number of elements crammed into one screen, overwhelming users and detracting from the site's usability.

8. Error messages are unclear and do not provide sufficient guidance to users, leaving them confused about how to resolve issues.

9. There is inadequate feedback provided on user actions, such as a lack of confirmation after submitting a form, leaving users uncertain about whether their actions have been successfully completed.

10. The touch target sizes on mobile devices are poorly designed and too small, making buttons difficult to tap accurately and leading to a frustrating user experience.
"""
    
    static func generateMockedLLM() -> LLMCaller {
        MockedLLMCallerService(mockedResultText: Self.mockedUsabilityIssues)
    }
}
