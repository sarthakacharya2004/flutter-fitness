// Commit 1
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFF121212),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.mark_email_read_outlined,
                  size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              Text(
                "Verify Your Email",
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    ?.copyWith(color: Colors.black),
              ),
              const SizedBox(height: 16),
              Text(
                "A verification link was sent to:\n${widget.email}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black87, fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text(
                "Check your inbox and click the link.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                Column(
                  children: [
                    const Text("Didn't get it?"),
                    TextButton(
                      onPressed: _resendVerificationEmail,
                      child: const Text("Resend Email"),
                    ),
                  ],
                ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text("Back"),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
