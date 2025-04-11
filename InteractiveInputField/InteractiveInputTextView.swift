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
    
    @Namespace var topID
    
    private struct Height {
        static let horizontalTags: CGFloat = 60
        static let selectedImageSession: CGFloat = 50
        static let bottomSheetBasic: CGFloat = 180
        static let bottomPhotoSelection: CGFloat = 230
        static let bottomPhotoSelectionThreshold: CGFloat = 100
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
                            .id(topID)
                        
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
                                    .frame(width: 50, height: 50)
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
                            
                            // Bottom photo selectionp view
                            if viewModel.bottomMode == .photo {
                                BottomPhotoSelectionView(selectedImage: $viewModel.selectedImage)
                                    .transition(AnyTransition.opacity.combined(with: .move(edge: .bottom)))
                            }
                        }
                        .transition(.move(edge: .bottom))
                    }
                    .frame(height:  bottomSheetHeight)
                    .scrollDismissesKeyboard(.interactively)
                    .onScrollGeometryChange(for: Double.self) { geometry in
                        geometry.contentOffset.y
                    } action: { passYOffset, currYOffset in
                        if currYOffset > Height.bottomPhotoSelectionThreshold {
                            showingPhotoPickerSheet = true
                        }
                    }
                    .onScrollPhaseChange { oldPhase, newPhase, context in
                        if newPhase == .idle {
                            if context.geometry.contentOffset.y < Height.bottomPhotoSelectionThreshold {
                                withAnimation {
                                    proxy.scrollTo(topID)
                                }
                            } else {
                                proxy.scrollTo(topID)
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showFullScreenTextInputView) {
            FullScreenTextInputView(
                message: $viewModel.message,
                switchToPhotoSelectionView: {
                    show(bottomMode: .photo)
                }, sendMessageAction: {
                    sendMessage()
                }
            )
        }
        .photosPicker(isPresented: $viewModel.showingPhotoPickerSheet, selection: $viewModel.selectedPhotoItem)
        .animation(.easeInOut, value: viewModel.selectedImage)
        .animation(.easeInOut, value: viewModel.bottomMode)
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
    
    private var bottomSheetHeight: CGFloat {
        var height: CGFloat = Height.bottomSheetBasic
        
        if viewModel.bottomMode == .photo {
            height += Height.bottomPhotoSelection
        }

        return height + selectedImageHeight + Height.horizontalTags
    }
    
    private var selectedImageHeight: CGFloat {
        return viewModel.selectedImage == nil ? 0 : Height.selectedImageSession
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

