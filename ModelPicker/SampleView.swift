//
//  SampleView.swift
//  ModelPicker
//
//  Created by Kyubo Shim on 2022/12/02.
//

import SwiftUI
import UIKit

struct SampleView: View {
    @Binding var selectedModel: Model?
    @Binding var backupModel: [Model]
    var body: some View {
        Text(selectedModel?.modelName ?? "null")
    }
}

struct SampleView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

