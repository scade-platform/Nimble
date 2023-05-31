
set(package_sources
    Language/Language.swift
    Language/Tokenizer.swift
    Language/Syntax.swift
    Language/Grammar.swift
    Language/SyntaxParser.swift
    Language/SyntaxColoring.swift
    Extensions/String+Encoding.swift
    Extensions/String+Ranges.swift
    Extensions/Range.swift
    Extensions/NSTextView.swift
    SourceCodeDocument.swift
    Core.swift
    Services/LanguageService.swift
    Services/Completion.swift
    Services/Types.swift)

add_library(CodeEditor STATIC)

foreach(source ${package_sources})
    target_sources(CodeEditor PRIVATE
                   ${CMAKE_CURRENT_SOURCE_DIR}/../../../Packages/CodeEditor/Sources/CodeEditor/${source})
endforeach()

swift_add_spm(SCOPE CodeEditorSPM
              URLS "git@github.com:FLORG1/oniguruma.git#branch=master")

target_link_libraries(CodeEditor PRIVATE NimbleCore CodeEditorSPM::Oniguruma)


add_library(CodeEditorPlugin SHARED)

# Set properties
set_target_properties(CodeEditorPlugin PROPERTIES
  FRAMEWORK TRUE
  MACOSX_BUNDLE_BUNDLE_NAME "CodeEditorPlugin"
  MACOSX_BUNDLE_BUNDLE_VERSION "${NIMBLE_VERSION}"
#  MACOSX_BUNDLE_GUI_IDENTIFIER "com.scade.Nimble"
  MACOSX_BUNDLE_COPYRIGHT "${NIMBLE_COPYRIGHT}"
  MACOSX_FRAMEWORK_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/Info.plist  
#  RESOURCE "${Nimble_RESOURCES}"
  INSTALL_RPATH "@executable_path;@executable_path/../Frameworks;@loader_path/../Frameworks"
#  BUILD_WITH_INSTALL_RPATH TRUE
)

set(plugin_sources
    CodeEditorView.swift
    DiagnosticView.swift
    CodeEditor.swift
    LineNumberView.swift
    Extensions/CodeEditorTextView+Navigation.swift
    Extensions/CodeEditorTextView+Snippets.swift
    Extensions/NSTextView.swift
    Extensions/CodeEditorTextView+Commands.swift
    Extensions/CodeEditorTextView+ColorTheme.swift
    Extensions/NSLayoutManager.swift
    Extensions/CodeEditorgTextView+Layout.swift
    Extensions/CodeEditorTextView+Formatting.swift
    CodeEditorCompletionView.swift
#    Settings.swift
    StatusBarView.swift
#    CotEditor/CurrentLineHighlighting.swift
#    CotEditor/TextContainer.swift
    CodeEditorMenu.swift
    CodeEditorTextView.swift
    CodeEditorLayoutManager.swift
    CodeEditorDocument.swift
    CodeEditorSettings.swift)

foreach(source ${plugin_sources})
  target_sources(CodeEditorPlugin PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/Sources/${source})
endforeach()

target_link_libraries(CodeEditorPlugin PRIVATE CodeEditor NimbleCore)
