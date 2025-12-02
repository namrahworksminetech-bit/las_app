import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:las_app/common_widgets/c_button.dart';
import 'package:las_app/features/abcl/bloc/abcl_bloc.dart';

class ConcernPage extends StatelessWidget {
  const ConcernPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Final Submit")),

      body: BlocConsumer<AbclBloc, AbclState>(
        listener: (context, state) {
          if (state.success) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Eligibility Submitted!")));
          }
        },

        builder: (context, state) {
          return Center(
            child: state.loader
                ? const CircularProgressIndicator()
                : CButton(
                    text: "Submit Application",
                    type: ButtonType.primaryWhite,
                    onPressed: () {
                      context.read<AbclBloc>().add(AbclSubmitConcernEvent());
                    },
                  ),
          );
        },
      ),
    );
  }
}
