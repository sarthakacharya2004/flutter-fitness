// Commit 3
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text("Verify Email", style: TextStyle(color: Colors.black)),
    ),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.email, size: 80, color: Colors.blue),
          const SizedBox(height: 20),
          Text(
            "Verification sent to\n${widget.email}",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          const Text(
            "Please check your inbox and click the link to verify.",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          if (_isLoading)
            const CircularProgressIndicator()
          else
            Column(
              children: [
                const Text("Didn't get the email?"),
                TextButton(
                  onPressed: _resendVerificationEmail,
                  child: const Text("Resend Email"),
                ),
              ],
            ),
        ],
      ),
    ),
  );
}
