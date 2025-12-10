import 'package:flutter/material.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_typography.dart';
import 'package:las_app/common_widgets/c_text.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  int? expandedIndex;

  final List<Map<String, String>> faqs = [
    {
        "question": "Which are the eligible mutual funds?",
        "helpful":
            '''Only mutual funds in non-demat form (i.e., in Statement of Accounts or physical form) are eligible Equity MFs are typically eligible for 45% of their market value, while debt MFs can offer up to 75%.'''
      },
      {
        "question": "Which are the non-eligible mutual funds?",
        "helpful": '''The following mutual funds are not eligible for a loan:
• Funds held in demat form
• Tax-saving ELSS funds with a 3-year lock-in period
• Funds that are already pledged
 Need help with demat MFs? Contact our support team to explore available options.'''
      },
      {
        "question":
            "What should I keep in mind while pledging mutual funds for a loan?",
        "helpful":
            '''•  Eligibility check: Make sure the mutual funds you're pledging are eligible.
• No redemption: You cannot redeem or transfer the pledged funds until the loan is fully repaid.
• Monthly interest: Interest payments are auto-debited each month.
• Late fees: Missing a payment may result in penalties.
'''
      },
      {
        "question": "How is the credit limit calculated?",
        "helpful":
            '''Your credit limit is determined based on the current market value of your pledged mutual funds:
• Up to 45% for equity mutual funds
• Up to 75% for debt mutual funds'''
      },
      {
        "question": "How is my monthly interest calculated?",
        "helpful":
            '''You pay only the monthly interest, based on the annual Rate of Interest (ROI).For example, on a ₹1,00,000 loan at 10.75% ROI, your monthly interest is ₹895.'''
      },
      {
        "question": "Can I get funding against joint accounts?",
        "helpful":
            '''Yes, you can pledge mutual funds held in joint accounts. However, both account holders must authorize the loan by signing the application.'''
      },
      {
        "question": "Can LAMF be used like a credit line?",
        "helpful":
            '''Yes, LAMF functions just like a credit line. You can borrow, repay, and withdraw again anytime within your approved limit, without the need to reapply each time. It’s flexible,convenient, and always accessible when you need it.'''
      },
      {
        "question":
            "What should I do if I face issues during loan disbursement or agreement signing?",
        "helpful":
            '''If you experience any issues, such as delayed loan disbursement or challenges during the agreement signing process, our support team is here to help. Simply reach out to us through the Help Center or use the chat option for quick assistance.
We’re here to ensure a smooth and hassle-free experience!
'''
      },
      {
        "question": "How can I manage my Loan?",
        "helpful":
            '''You can manage your loan, repayments, and withdrawals from the loan dashboard on the ValuEnable app.'''
      },
      {
        "question": "What are the interest deductions and penalties?",
        "helpful":
            '''•  Interest deduction: Your monthly interest is auto-debited from your linked account.
• Late payment penalties: If a payment is missed, a bounce charge of ₹1,200 will apply. 
• Additionally, a 2% late fee will be charged on the overdue amount.
'''
      },
      {
        "question": "Does pledging mutual funds have any tax implications?",
        "helpful":
            '''Pledging mutual funds does not directly impact your taxes. However, if the pledged funds are sold at any point, capital gains tax may apply, and the calculation will depend on the holding period of the investment.'''
      },
      {
        "question": "What happens if the value of my mutual fund falls?",
        "helpful":
            '''If the value of your pledged mutual funds decreases, you may need to take action to maintain the required loan-to-value ratio:
• Equity MFs: Maintain at least 45% of the current value.
• Debt MFs: Maintain at least 75% of the current value.
'''
      },
      {
        "question":
            "What happens if the loan-to-value ratio is breached or the loan is not repaid on time?",
        "helpful":
            '''If your loan-to-value ratio is breached or if the loan remains unpaid beyond the agreed tenure, your pledged mutual funds may be liquidated to recover the outstanding balance.To avoid this, ensure timely repayments and monitor your loan-to-value ratio regularly
'''
      },
      {
        "question":
            "When can I unpledge my mutual funds, and is partial unpledging allowed?",
        "helpful":
            '''You can unpledge your mutual funds only after the loan is fully repaid.Currently, partial unpledging is not supported.Keep track of your loan status for a smooth unpledging process once it's paid off!
'''
      },
      {
        "question": "What are the options for Loan Repayment?",
        "helpful":
            '''You can repay the loan fully or partially at any time via the loan dashboard.'''
      },
      {
        "question": "How can I repay and close my loan?",
        "helpful":
            '''Yes, LAMF functions just like a credit line. You can borrow, repay, and withdraw again anytime within your approved limit, without the need to reapply each time. It’s flexible,convenient, and always accessible when you need it.'''
      },
      {
        "question": "Can I foreclose my loan early, and are there any charges?",
        "helpful":
            '''Yes, you can foreclose your loan at any time without any foreclosure charges, as long as all dues are cleared.
Enjoy the flexibility of early loan closure with no extra cost
'''
      },

  ];

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        title: Text(
          "Help & FAQs",
          style: AppTypography.bodyWhite.copyWith(fontSize: 16),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final item = faqs[index];
          final isOpen = expandedIndex == index;

          return Column(
            children: [
              // ------------------- QUESTION ROW -------------------
              InkWell(
                onTap: () {
                  setState(() {
                    expandedIndex = isOpen ? null : index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isOpen
                          ? AppColors.bPrimaryColor
                          : AppColors.bSecondaryColor.withValues(alpha:0.4),
                      width: 1.2,
                    ),
                    boxShadow: isOpen
                        ? [
                            BoxShadow(
                              color: AppColors.bPrimaryColor.withValues(alpha:0.25),
                              spreadRadius: 2,
                              blurRadius: 8,
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: CText(
                          item["question"]!,
                          style: AppTypography.bodyWhite.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        isOpen ? Icons.expand_less : Icons.expand_more,
                        color: AppColors.bSecondaryColor,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              // ------------------- ANSWER BOX -------------------
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 250),
                crossFadeState:
                    isOpen ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                firstChild: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151515),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.bPrimaryColor.withValues(alpha:0.35),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    item["helpful"]!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.bSecondaryColor.withValues(alpha:0.85),
                      fontSize: 14.5,              // 🔥 Increased text size
                      height: 1.55,                // 🔥 Better readability
                    ),
                  ),
                ),
                secondChild: const SizedBox.shrink(),
              ),
            ],
          );
        },
      ),
    );
  }
}