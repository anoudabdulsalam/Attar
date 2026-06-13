const axios = require("axios");

const herbChat = async (req, res) => {
  try {
    const { message } = req.body;

    if (!message || !message.trim()) {
      return res.status(400).json({
        message: "Message is required",
      });
    }

    const ollamaResponse = await axios.post("http://localhost:11434/api/chat", {
      model: "qwen2.5:3b",
     messages: [
        {
          role: "system",
          content: `
أنت مساعد ذكي عام متخصص بالأعشاب الطبيعية والعناية الصحية العامة.

التزم بهذه القواعد:
1. أجب بالعربية فقط.
2. لا تستخدم الإنجليزية أو الصينية أو أي لغة أخرى.
3. إذا كان سؤال المستخدم غير واضح، اسأله سؤالًا توضيحيًا قبل الإجابة.
4. إذا كان السؤال عن الأعشاب، اقترح 2 أو 3 أعشاب فقط.
5. اذكر فائدة مختصرة وطريقة استخدام مختصرة.
6. إذا بدت الحالة خطيرة أو فيها ألم شديد أو استمرار طويل، انصح بمراجعة الطبيب.
7. لا تعطِ تشخيصًا طبيًا مؤكدًا.
8. اجعل الرد واضحًا، مختصرًا، ومرتبًا.
9. لا تكتب أي رموز غريبة أو كلمات أجنبية.
10. إذا لم تكن متأكدًا، قل ذلك بوضوح.
`,
        },
        {
          role: "user",
          content: message,
        },
      ],
      stream: false,
    });

    const reply =
      ollamaResponse.data?.message?.content?.trim() ||
      "عذرًا، لم أتمكن من توليد رد مناسب الآن.";

    return res.status(200).json({
      message: "AI reply generated successfully",
      reply,
    });
  } catch (error) {
    return res.status(500).json({
      message: "AI chat error",
      error: error.message,
    });
  }
};

module.exports = { herbChat };