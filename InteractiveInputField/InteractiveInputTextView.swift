//
//  InteractiveInputTextView.swift
//  InteractiveInputField
//
//  Created by Chris Ng on 2025-03-27.
//

import SwiftUI
import PhotosUI

struct InteractiveInputTextView: View {
    
    @State var viewModel: InteractiveInputTextViewModel = InteractiveInputTextViewModel()
    @FocusState private var isFocusedKeyboard: Bool
    
    @Namespace private var bottomSheetTopID
    @Namespace private var bottomPhotoTopID
    @Namespace private var transitionNamespace
    
    private static let photoTransitionID: String = "photo"
    private static let textEditorTransitionID: String = "text"
    
    private struct Height {
        static let horizontalTags: CGFloat = 60
        static let selectedImageSession: CGFloat = 50
        static let bottomSheetBasic: CGFloat = 180
        static let bottomPhotoSelection: CGFloat = 200
        static let bottomPhotoSelectionThreshold: CGFloat = 100
        static let dismissBottomPhotoSheetThresholdYOffset: CGFloat = -80
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.appBackground.ignoresSafeArea()
            
            VStack {
                Text("Some Text")
                    .font(.headline)
                Spacer()
                
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        horizontalTags
                            .id(bottomSheetTopID)
                        
                        //top shadow
                        Color.appBackground
                            .frame(maxWidth: .infinity, maxHeight: 10)
                            .clipShape(TopRoundedShape(radius: 10))
                            .shadow(color: .gray, radius: 2, x:0, y: -3)
                        
                        // Bottom Sheet / Input Field
                        VStack(alignment: .leading, spacing: 16) {
                            
                            // Textfield and expand icon
                            HStack(alignment: .top) {
                                DynamicFontSizeTextEditor(text: $viewModel.message, isFocused: $isFocusedKeyboard) { isFocused in
                                    if isFocused {
                                        show(bottomMode: .keyboard)
                                    }
                                }
                                .matchedTransitionSource(id: Self.textEditorTransitionID, in: transitionNamespace)
                                
                                if !viewModel.message.isEmpty {
                                    Button {
                                        viewModel.showFullScreenTextInputView.toggle()
                                    } label: {
                                        Image(systemName: Constants.Icon.expand)
                                            .padding(.top, 8)
                                            .applyAppButtonStyle()
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            // Selected image
                            if let image = viewModel.selectedImage {
                                HStack {
                                    ZStack(alignment: .topTrailing) {
                                        Color.clear
                                            .aspectRatio(1, contentMode: .fit)
                                            .overlay(
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 5))
                                            .padding(2)
                                        closeButton
                                    }
                                    .frame(width: Height.selectedImageSession, height: Height.selectedImageSession)
                                }
                                .padding(.horizontal)
                            }
                            
                            // Bottom buttons
                            BottomSheetButtonsBar(photoPickerAction: {
                                let nextMode: InteractiveInputTextViewModel.BottomMode = viewModel.bottomMode == .photo ? .none : .photo
                                show(bottomMode: nextMode)
                            }, sendAction: {
                                sendMessage()
                            })
                            .padding(.horizontal)
                            
                            // Bottom photo selection sheet view
                            if viewModel.bottomMode == .photo {
                                bottomPhotoSheet(with: proxy)
                            }
                           
                        }
                        
                    }
                    .frame(height: bottomSheetHeight)
                    .animation(.easeInOut, value: bottomSheetHeight)
                    .scrollDismissesKeyboard(.interactively)
                    .onScrollGeometryChange(for: Double.self) { geometry in
                        geometry.contentOffset.y
                    } action: { passYOffset, currYOffset in
                        if currYOffset > 0 {
                            // don't allow bottomSheet scrollView to scroll over the top
                            proxy.scrollTo(bottomSheetTopID)
                        }
                    }
                    .onScrollPhaseChange { oldPhase, newPhase, context in
                        if newPhase == .idle {
                            if context.geometry.contentOffset.y < Height.bottomPhotoSelectionThreshold {
                                withAnimation {
                                    proxy.scrollTo(bottomSheetTopID)
                                }
                            } else {
                                proxy.scrollTo(bottomSheetTopID)
                            }
                        } else if newPhase == .decelerating {
                            if viewModel.bottomMode == .photo, context.geometry.contentOffset.y < Height.dismissBottomPhotoSheetThresholdYOffset {
                                show(bottomMode: .none)
                            }
                        }
                    }
                }
            }
        }
        .popover(isPresented: $viewModel.showFullScreenTextInputView) {
            FullScreenTextInputView(
                message: $viewModel.message,
                switchToPhotoSelectionView: {
                    show(bottomMode: .photo)
                }, sendMessageAction: {
                    sendMessage()
                }
            )
            .navigationTransition(.zoom(sourceID: Self.textEditorTransitionID, in: transitionNamespace))
        }
        .popover(isPresented: $viewModel.showingPhotoPickerSheet) {
            BottomPhotoSelectionSheetView(selectedImage: $viewModel.selectedImage)
                .navigationTransition(.zoom(sourceID: Self.photoTransitionID, in: transitionNamespace))
        }
        .onChange(of: viewModel.selectedImage) {
            viewModel.bottomMode = .none
        }
        .onChange(of: viewModel.selectedPhotoItem) {
            Task {
                guard let selectedPhotoItem = viewModel.selectedPhotoItem else { return }
                
                if let loaded = try? await selectedPhotoItem.loadTransferable(type: Image.self) {
                    viewModel.selectedImage = loaded
                } else {
                    debugPrint("Failed to load image")
                }
            }
        }
    }
    
    private var horizontalTags: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(0...5, id: \.self) { _ in
                    VStack(alignment: .leading) {
                        Text("Some Text")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Some more text")
                            .font(.system(size: 12))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.tagBackground)
                    .clipShape(Capsule())
                }
            }
            .padding()
        }
        .frame(height: Height.horizontalTags)
    }
    
    private func bottomPhotoSheet(with scrollViewProxy: ScrollViewProxy) -> some View {
        ScrollView {
            BottomPhotoSelectionView(selectedImage: $viewModel.selectedImage)
                .id(bottomPhotoTopID)
                .matchedTransitionSource(id: Self.photoTransitionID, in: transitionNamespace)

        }
        .frame(height: Height.bottomPhotoSelection)
        .transition(AnyTransition.opacity.combined(with: .move(edge: .bottom)))
        .scrollClipDisabled()
        .onScrollGeometryChange(for: Double.self) { geometry in
            geometry.contentOffset.y
        } action: { passYOffset, currYOffset in
            guard viewModel.bottomMode == .photo else { return }
            
            if currYOffset > Height.bottomPhotoSelectionThreshold {
                viewModel.showingPhotoPickerSheet = true
            }
        }
        .onScrollPhaseChange { oldPhase, newPhase, context in
            let yOffset = context.geometry.contentOffset.y
            if newPhase == .idle {
                if yOffset < Height.bottomPhotoSelectionThreshold {
                    withAnimation {
                        scrollViewProxy.scrollTo(bottomPhotoTopID, anchor: .top)
                    }
                } else {
                    scrollViewProxy.scrollTo(bottomPhotoTopID, anchor: .top)
                }
            }
        }
    }
    
    private var bottomSheetHeight: CGFloat {
        var height: CGFloat = Height.bottomSheetBasic
        
        if viewModel.bottomMode == .photo {
            height += Height.bottomPhotoSelection
        }

        return height + selectedImageHeight + Height.horizontalTags
    }
    
    private var selectedImageHeight: CGFloat {
        let padding: CGFloat = 10
        return viewModel.selectedImage == nil ? 0 : Height.selectedImageSession + padding
    }
    
    private var closeButton: some View {
        Button(action: {
            viewModel.selectedPhotoItem = nil
            viewModel.selectedImage = nil
        }) {
            Image(systemName: Constants.Icon.removePhoto)
                .foregroundStyle(.white, .black)
                .applyAppButtonStyle()
        }
    }
    
    private func show(bottomMode: InteractiveInputTextViewModel.BottomMode) {
        self.isFocusedKeyboard = bottomMode == .keyboard
        self.viewModel.bottomMode = bottomMode
    }

    private func sendMessage() {
        debugPrint("Send message: '\(viewModel.message)'")
    }
}

struct InteractiveInputTextView_Previews: PreviewProvider {
    static var previews: some View {
        InteractiveInputTextView()
    }
}

